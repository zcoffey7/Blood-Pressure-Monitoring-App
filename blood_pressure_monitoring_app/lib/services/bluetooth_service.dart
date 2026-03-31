import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../constants/ble_constants.dart';
import '../models/ppg_packet.dart';

/// Low-level BLE wrapper for the ESP32 PPG sensor board.
///
/// Responsibilities:
///  - Scan, connect, discover service/characteristic per the interface spec.
///  - Enable notifications on the PPG data characteristic.
///  - Parse incoming binary packets into [PpgPacket] objects.
///  - Track packet_seq and report sequence gaps.
class BluetoothService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataCh;
  BluetoothCharacteristic? _cmdCh;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamSubscription<List<int>>? _notifySub;

  final _ppgController = StreamController<PpgPacket>.broadcast();
  final _gapController = StreamController<PacketGap>.broadcast();

  bool _isDisposed = false;
  bool _notificationsActive = false;
  int? _lastSeq;

  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Parsed PPG packets from notifications.
  Stream<PpgPacket> get ppgStream => _ppgController.stream;

  /// Emits whenever a sequence gap is detected.
  Stream<PacketGap> get gapStream => _gapController.stream;

  // ── Adapter State ──────────────────────────────────────────────

  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  Future<bool> get isBluetoothOn async {
    final state = await FlutterBluePlus.adapterState.first;
    debugPrint('BLE: adapter state = $state');
    return state == BluetoothAdapterState.on;
  }

  // ── Scanning ───────────────────────────────────────────────────

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  bool get isScanning => FlutterBluePlus.isScanningNow;

  Future<void> startScan() async {
    debugPrint('BLE: starting scan (timeout=${BleConstants.scanTimeout.inSeconds}s)');

    await FlutterBluePlus.startScan(
      timeout: BleConstants.scanTimeout,
      androidUsesFineLocation: true,
    );

    debugPrint('BLE: scan completed');
  }

  Future<void> stopScan() async {
    debugPrint('BLE: stopping scan');
    await FlutterBluePlus.stopScan();
  }

  // ── Connection ─────────────────────────────────────────────────

  bool get isDeviceConnected => _connectedDevice?.isConnected ?? false;

  Stream<BluetoothConnectionState> get connectionState {
    if (_connectedDevice == null) {
      return Stream.value(BluetoothConnectionState.disconnected);
    }
    return _connectedDevice!.connectionState;
  }

  Future<void> connect(BluetoothDevice device) async {
    debugPrint('BLE: connecting to ${device.platformName} '
        '(${device.remoteId})...');

    await device.connect(
      timeout: BleConstants.connectionTimeout,
      autoConnect: false,
    );
    _connectedDevice = device;
    _lastSeq = null;

    debugPrint('BLE: connected to ${device.platformName}');

    _connectionSub?.cancel();
    _connectionSub = device.connectionState.listen((state) {
      debugPrint('BLE: connection state changed → $state');
      if (state == BluetoothConnectionState.disconnected) {
        _onDisconnected();
      }
    });

    await _discoverAndSubscribe(device);
  }

  Future<void> disconnect() async {
    debugPrint('BLE: disconnecting...');
    _notifySub?.cancel();
    _notifySub = null;
    _connectionSub?.cancel();
    _connectionSub = null;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (_) {}
    }
    _onDisconnected();
    debugPrint('BLE: disconnected');
  }

  // ── Service Discovery & Notification Subscription ──────────────

  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    _notifySub?.cancel();
    _notifySub = null;

    debugPrint('BLE: discovering services...');
    final services = await device.discoverServices();
    debugPrint('BLE: found ${services.length} services');

    for (final service in services) {
      debugPrint('  service: ${service.uuid} '
          '(${service.characteristics.length} characteristics)');
      for (final ch in service.characteristics) {
        debugPrint('    char: ${ch.uuid} '
            'props: ${ch.properties}');
      }
    }

    BluetoothCharacteristic? dataCh;
    BluetoothCharacteristic? cmdCh;

    for (final service in services) {
      if (service.uuid == BleConstants.serviceUuid) {
        debugPrint('BLE: found PPG service ${service.uuid}');
        for (final ch in service.characteristics) {
          if (ch.uuid == BleConstants.dataCharUuid) {
            dataCh = ch;
            debugPrint('BLE: found PPG data characteristic ${ch.uuid}');
          } else if (ch.uuid == BleConstants.cmdCharUuid) {
            cmdCh = ch;
            debugPrint('BLE: found command characteristic ${ch.uuid}');
          }
        }
        break;
      }
    }

    if (dataCh == null) {
      debugPrint('BLE: ERROR — PPG data characteristic not found!');
      debugPrint('  expected service:  ${BleConstants.serviceUuid}');
      debugPrint('  expected char:     ${BleConstants.dataCharUuid}');
      throw Exception(
        'PPG data characteristic ${BleConstants.dataCharUuid} not found '
        'under service ${BleConstants.serviceUuid}. '
        'Check that ESP32 firmware matches the interface spec.',
      );
    }

    _dataCh = dataCh;
    _cmdCh = cmdCh;

    if (cmdCh == null) {
      debugPrint('BLE: WARNING — command characteristic not found; '
          'pump control will be unavailable');
    }

    debugPrint('BLE: enabling notifications on ${dataCh.uuid}...');
    await dataCh.setNotifyValue(true);
    _notificationsActive = true;
    debugPrint('BLE: notifications enabled — streaming PPG data');

    _notifySub = dataCh.onValueReceived.listen(_onNotification);
  }

  // ── Pause / Resume Notifications ─────────────────────────────

  bool get isNotifying => _notificationsActive;

  Future<void> pauseNotifications() async {
    final ch = _dataCh;
    if (ch == null || !_notificationsActive) return;

    debugPrint('BLE: pausing notifications...');
    _notifySub?.cancel();
    _notifySub = null;
    await ch.setNotifyValue(false);
    _notificationsActive = false;
    debugPrint('BLE: notifications paused');
  }

  Future<void> resumeNotifications() async {
    final ch = _dataCh;
    if (ch == null || _notificationsActive) return;

    debugPrint('BLE: resuming notifications...');
    await ch.setNotifyValue(true);
    _notificationsActive = true;
    _notifySub = ch.onValueReceived.listen(_onNotification);
    debugPrint('BLE: notifications resumed');
  }

  void _onNotification(List<int> value) {
    if (_isDisposed) return;

    final packet = PpgPacket.tryParse(value);
    if (packet == null) {
      debugPrint('BLE: malformed PPG packet (${value.length} bytes)');
      return;
    }

    // Sequence-gap detection (spec section 6).
    // Note: uint32 wraparound (~4 billion packets) is silently tolerated
    // via the `missed > 0` guard; practically unreachable.
    if (_lastSeq != null) {
      final expected = _lastSeq! + 1;
      if (packet.packetSeq != expected) {
        final missed = packet.packetSeq - expected;
        if (missed > 0) {
          _gapController.add(PacketGap(
            expectedSeq: expected,
            receivedSeq: packet.packetSeq,
            missedPackets: missed,
          ));
          debugPrint(
            'BLE: packet gap — expected seq $expected, '
            'got ${packet.packetSeq} ($missed missed)',
          );
        }
      }
    }
    _lastSeq = packet.packetSeq;

    _ppgController.add(packet);
  }

  // ── Pump Command ───────────────────────────────────────────────

  bool get hasCmdCharacteristic => _cmdCh != null;

  Future<void> sendPumpCommand(bool on) async {
    final ch = _cmdCh;
    if (ch == null) {
      throw Exception('Command characteristic not available. '
          'Ensure the device is connected and firmware supports pump control.');
    }

    final byte = on ? BleConstants.pumpOn : BleConstants.pumpOff;
    debugPrint('BLE: sending pump command ${on ? "ON" : "OFF"} (0x${byte.toRadixString(16)})');
    await ch.write([byte], withoutResponse: true);
    debugPrint('BLE: pump command sent');
  }

  // ── Cleanup ────────────────────────────────────────────────────

  void _onDisconnected() {
    _notifySub?.cancel();
    _notifySub = null;
    _dataCh = null;
    _cmdCh = null;
    _notificationsActive = false;
    _connectedDevice = null;
    _lastSeq = null;
    debugPrint('BLE: device disconnected — state reset');
  }

  void dispose() {
    _isDisposed = true;
    _notifySub?.cancel();
    _connectionSub?.cancel();
    _ppgController.close();
    _gapController.close();
  }
}

/// Describes a gap in the packet sequence.
class PacketGap {
  final int expectedSeq;
  final int receivedSeq;
  final int missedPackets;

  const PacketGap({
    required this.expectedSeq,
    required this.receivedSeq,
    required this.missedPackets,
  });

  @override
  String toString() =>
      'PacketGap(expected=$expectedSeq, received=$receivedSeq, '
      'missed=$missedPackets)';
}
