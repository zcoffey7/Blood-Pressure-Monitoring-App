import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/device_connection.dart';
import '../repositories/device_repository.dart';

/// Controller for device connection management
/// Follows SRP - Only manages device connection state
/// Uses Provider for state management
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

  // Getters
  DeviceConnection? get connection => _connection;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  bool get isConnected => _connection?.isConnected ?? false;
  int get batteryLevel => _connection?.batteryLevel ?? 0;

  /// Initialize controller and load connection status
  Future<void> _initialize(bool enableMonitoring) async {
    await loadConnectionStatus();
    if (enableMonitoring) {
      _startConnectionMonitoring();
    }
  }

  /// Load current connection status
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

  /// Connect to device
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

  /// Disconnect from device
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

  /// Sync data with device
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

  /// Start monitoring connection status changes
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

  /// Refresh connection status
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
