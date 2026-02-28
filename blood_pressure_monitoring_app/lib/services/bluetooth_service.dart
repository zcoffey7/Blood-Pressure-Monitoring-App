import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../constants/ble_constants.dart';

/// Low-level BLE operations wrapper around flutter_blue_plus.
/// Keeps the rest of the app BLE-library-agnostic.
class BluetoothService {
  BluetoothDevice? _connectedDevice;
  final Map<String, BluetoothCharacteristic> _characteristics = {};
  final _heartRateController = StreamController<int>.broadcast();
  final _batteryLevelController = StreamController<int>.broadcast();
  StreamSubscription<BluetoothConnectionState>? _connectionSub;

  BluetoothDevice? get connectedDevice => _connectedDevice;

  Stream<int> get heartRateStream => _heartRateController.stream;
  Stream<int> get batteryLevelStream => _batteryLevelController.stream;

  // ── Adapter State ──────────────────────────────────────────────

  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  Future<bool> get isBluetoothOn async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  // ── Scanning ───────────────────────────────────────────────────

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  bool get isScanning => FlutterBluePlus.isScanningNow;

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(
      withServices: [BleConstants.serviceUuid],
      timeout: BleConstants.scanTimeout,
      androidUsesFineLocation: true,
    );
  }

  Future<void> stopScan() async {
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
    await device.connect(
      timeout: BleConstants.connectionTimeout,
      autoConnect: false,
    );
    _connectedDevice = device;

    _connectionSub?.cancel();
    _connectionSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _onDisconnected();
      }
    });

    await _discoverAndSubscribe(device);
  }

  Future<void> disconnect() async {
    _connectionSub?.cancel();
    _connectionSub = null;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (_) {
        // Device may already be disconnected
      }
    }
    _onDisconnected();
  }

  // ── Characteristic Discovery & Subscription ────────────────────

  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    final services = await device.discoverServices();

    bool found = false;
    for (final service in services) {
      if (service.uuid == BleConstants.serviceUuid) {
        found = true;
        for (final char in service.characteristics) {
          _characteristics[char.uuid.toString()] = char;
        }
        break;
      }
    }

    if (!found) {
      throw Exception(
          'ESP32 service not found. Ensure firmware advertises ${BleConstants.serviceUuid}');
    }

    await _subscribeToHeartRate();
    await _subscribeToBattery();
  }

  Future<void> _subscribeToHeartRate() async {
    final char =
        _characteristics[BleConstants.heartRateCharUuid.toString()];
    if (char == null) {
      debugPrint('Heart rate characteristic not found');
      return;
    }

    await char.setNotifyValue(true);
    char.onValueReceived.listen((value) {
      if (value.isNotEmpty) {
        _heartRateController.add(value[0]);
      }
    });
  }

  Future<void> _subscribeToBattery() async {
    final char =
        _characteristics[BleConstants.batteryLevelCharUuid.toString()];
    if (char == null) {
      debugPrint('Battery level characteristic not found');
      return;
    }

    // Read initial value
    try {
      final initial = await char.read();
      if (initial.isNotEmpty) {
        _batteryLevelController.add(initial[0]);
      }
    } catch (_) {
      // Non-critical: we'll get updates via notify
    }

    await char.setNotifyValue(true);
    char.onValueReceived.listen((value) {
      if (value.isNotEmpty) {
        _batteryLevelController.add(value[0]);
      }
    });
  }

  // ── Cleanup ────────────────────────────────────────────────────

  void _onDisconnected() {
    _connectedDevice = null;
    _characteristics.clear();
  }

  void dispose() {
    _connectionSub?.cancel();
    _heartRateController.close();
    _batteryLevelController.close();
  }
}
