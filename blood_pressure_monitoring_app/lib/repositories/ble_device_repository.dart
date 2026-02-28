import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'
    hide BluetoothService;

import '../models/device_connection.dart';
import '../services/bluetooth_service.dart';
import 'device_repository.dart';

/// Real BLE implementation of [DeviceRepository].
/// Connects to an ESP32 blood pressure monitor via Bluetooth Low Energy
/// and streams heart rate + battery level from BLE notifications.
class BleDeviceRepository implements DeviceRepository {
  final BluetoothService _bleService;
  final _connectionController = StreamController<DeviceConnection>.broadcast();

  StreamSubscription<int>? _heartRateSub;
  StreamSubscription<int>? _batterySub;
  StreamSubscription<BluetoothConnectionState>? _stateSub;

  int _lastBattery = 0;
  int? _lastHeartRate;
  BluetoothDevice? _targetDevice;

  BleDeviceRepository(this._bleService);

  // ── Scan API (not part of DeviceRepository — used by controller) ──

  Stream<List<ScanResult>> get scanResults => _bleService.scanResults;

  bool get isScanning => _bleService.isScanning;

  Future<void> startScan() => _bleService.startScan();

  Future<void> stopScan() => _bleService.stopScan();

  /// Set the device to connect to (chosen from scan results).
  void selectDevice(BluetoothDevice device) {
    _targetDevice = device;
  }

  // ── DeviceRepository implementation ────────────────────────────

  @override
  Future<DeviceConnection> getConnectionStatus() async {
    return DeviceConnection(
      isConnected: _bleService.isDeviceConnected,
      batteryLevel: _lastBattery,
      heartRate: _lastHeartRate,
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
    _lastHeartRate = null;
    _lastBattery = 0;
    _emitStatus();
  }

  @override
  Future<bool> syncDevice() async {
    // Real-time notify mode — no batch sync needed.
    // Return true if connected so the UI shows success.
    return _bleService.isDeviceConnected;
  }

  @override
  Stream<DeviceConnection> watchConnectionStatus() {
    return _connectionController.stream;
  }

  // ── Internal ───────────────────────────────────────────────────

  void _listenToStreams() {
    _cancelSubscriptions();

    _heartRateSub = _bleService.heartRateStream.listen((hr) {
      _lastHeartRate = hr;
      _emitStatus();
    });

    _batterySub = _bleService.batteryLevelStream.listen((level) {
      _lastBattery = level;
      _emitStatus();
    });

    _stateSub = _bleService.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _lastHeartRate = null;
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
    _heartRateSub?.cancel();
    _batterySub?.cancel();
    _stateSub?.cancel();
  }

  void dispose() {
    _cancelSubscriptions();
    _connectionController.close();
    _bleService.dispose();
  }
}
