import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'
    hide BluetoothService;

import '../models/device_connection.dart';
import '../repositories/ble_device_repository.dart';
import '../repositories/device_repository.dart';

/// Controller for device connection management.
/// Supports both [BleDeviceRepository] (real BLE) and any [DeviceRepository]
/// (mock, test). Scan/select features are only available with BLE.
class DeviceController extends ChangeNotifier {
  final DeviceRepository _repository;

  DeviceConnection? _connection;
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  bool _isDisposed = false;
  StreamSubscription<DeviceConnection>? _connectionSubscription;

  DeviceController(this._repository, {bool enableMonitoring = true}) {
    _initialize(enableMonitoring);
  }

  // ── Getters ────────────────────────────────────────────────────

  DeviceConnection? get connection => _connection;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  bool get isConnected => _connection?.isConnected ?? false;
  int? get heartRate => _connection?.heartRate;

  /// Whether the underlying repository supports BLE scanning.
  bool get canScan => _repository is BleDeviceRepository;

  bool get isScanning =>
      _repository is BleDeviceRepository && _repository.isScanning;

  Stream<List<ScanResult>> get scanResults {
    if (_repository is BleDeviceRepository) {
      return _repository.scanResults;
    }
    return const Stream.empty();
  }

  // ── Initialization ─────────────────────────────────────────────

  Future<void> _initialize(bool enableMonitoring) async {
    await loadConnectionStatus();
    if (enableMonitoring) {
      _startConnectionMonitoring();
    }
  }

  // ── Connection Status ──────────────────────────────────────────

  Future<void> loadConnectionStatus() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _connection = await _repository.getConnectionStatus();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load connection status: $e';
      notifyListeners();
    }
  }

  // ── Scan & Select (BLE only) ───────────────────────────────────

  Future<void> startScan() async {
    if (_repository is! BleDeviceRepository) return;
    try {
      _error = null;
      notifyListeners();
      await _repository.startScan();
      notifyListeners();
    } catch (e) {
      _error = 'Scan failed: $e';
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    if (_repository is! BleDeviceRepository) return;
    await _repository.stopScan();
    notifyListeners();
  }

  void selectDevice(BluetoothDevice device) {
    if (_repository is BleDeviceRepository) {
      _repository.selectDevice(device);
    }
  }

  // ── Connect / Disconnect ───────────────────────────────────────

  Future<bool> connect() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _repository.connectDevice();

      if (success) {
        _connection = await _repository.getConnectionStatus();
      }

      _isLoading = false;
      notifyListeners();

      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to connect to device: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.disconnectDevice();
      _connection = await _repository.getConnectionStatus();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to disconnect from device: $e';
      notifyListeners();
    }
  }

  // ── Sync ───────────────────────────────────────────────────────

  Future<bool> syncDevice() async {
    try {
      _isSyncing = true;
      _error = null;
      notifyListeners();

      final success = await _repository.syncDevice();

      if (success) {
        _connection = await _repository.getConnectionStatus();
      }

      _isSyncing = false;
      notifyListeners();

      return success;
    } catch (e) {
      _isSyncing = false;
      _error = 'Failed to sync device: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Monitoring ─────────────────────────────────────────────────

  void _startConnectionMonitoring() {
    _connectionSubscription = _repository.watchConnectionStatus().listen(
      (connection) {
        _connection = connection;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Connection monitoring error: $error';
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    await loadConnectionStatus();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectionSubscription?.cancel();
    super.dispose();
  }
}
