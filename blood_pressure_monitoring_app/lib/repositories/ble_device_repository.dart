import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'
    hide BluetoothService;

import '../models/device_connection.dart';
import '../models/ppg_packet.dart';
import '../services/bluetooth_service.dart';
import 'device_repository.dart';

/// Real BLE implementation of [DeviceRepository].
/// Connects to the ESP32 PPG sensor board via Bluetooth Low Energy
/// and streams parsed PPG packets from BLE notifications.
class BleDeviceRepository implements DeviceRepository {
  final BluetoothService _bleService;
  final _connectionController = StreamController<DeviceConnection>.broadcast();

  StreamSubscription<PpgPacket>? _ppgSub;
  StreamSubscription<BluetoothConnectionState>? _stateSub;

  BluetoothDevice? _targetDevice;

  BleDeviceRepository(this._bleService);

  // ── Scan API (not part of DeviceRepository — used by controller) ──

  Stream<List<ScanResult>> get scanResults => _bleService.scanResults;

  bool get isScanning => _bleService.isScanning;

  Future<void> startScan() => _bleService.startScan();

  Future<void> stopScan() => _bleService.stopScan();

  void selectDevice(BluetoothDevice device) {
    _targetDevice = device;
  }

  // ── PPG data (available to consumers that need raw samples) ────

  /// Live PPG packets from the sensor. Active only while connected.
  Stream<PpgPacket> get ppgStream => _bleService.ppgStream;

  /// Sequence gap events for debugging / UI indicators.
  Stream<PacketGap> get gapStream => _bleService.gapStream;

  /// Pause BLE notifications (stops data from the sensor).
  Future<void> pauseNotifications() => _bleService.pauseNotifications();

  /// Resume BLE notifications (restarts data from the sensor).
  Future<void> resumeNotifications() => _bleService.resumeNotifications();

  // ── DeviceRepository implementation ────────────────────────────

  @override
  Future<DeviceConnection> getConnectionStatus() async {
    return DeviceConnection(
      isConnected: _bleService.isDeviceConnected,
      lastSyncTime: _bleService.isDeviceConnected ? DateTime.now() : null,
      deviceName: _bleService.connectedDevice?.platformName ??
          _targetDevice?.platformName ??
          'No Device',
      connectionType: ConnectionType.bluetooth,
    );
  }

  @override
  Future<bool> connectDevice() async {
    final device = _targetDevice;
    if (device == null) {
      throw Exception('No device selected. Scan and select a device first.');
    }

    try {
      await _bleService.connect(device);
      _listenToStreams();
      return true;
    } catch (e) {
      debugPrint('BLE connect failed: $e');
      return false;
    }
  }

  @override
  Future<void> disconnectDevice() async {
    _cancelSubscriptions();
    await _bleService.disconnect();
    _emitStatus();
  }

  @override
  Future<bool> syncDevice() async {
    return _bleService.isDeviceConnected;
  }

  @override
  Stream<DeviceConnection> watchConnectionStatus() {
    return _connectionController.stream;
  }

  // ── Internal ───────────────────────────────────────────────────

  void _listenToStreams() {
    _cancelSubscriptions();

    _ppgSub = _bleService.ppgStream.listen((_) {
      _emitStatus();
    });

    _stateSub = _bleService.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _emitStatus();
      }
    });

    _emitStatus();
  }

  void _emitStatus() {
    getConnectionStatus().then((status) {
      if (!_connectionController.isClosed) {
        _connectionController.add(status);
      }
    });
  }

  void _cancelSubscriptions() {
    _ppgSub?.cancel();
    _stateSub?.cancel();
  }

  void dispose() {
    _cancelSubscriptions();
    _connectionController.close();
    _bleService.dispose();
  }
}
