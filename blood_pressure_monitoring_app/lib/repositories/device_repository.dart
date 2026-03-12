import '../models/device_connection.dart';

/// Repository for device connection data
/// Follows Repository Pattern - Easy to swap implementation with real Bluetooth/WiFi
/// Follows OCP - Can extend with new connection types without modifying existing code
abstract class DeviceRepository {
  /// Get current device connection status
  Future<DeviceConnection> getConnectionStatus();

  /// Connect to device
  Future<bool> connectDevice();

  /// Disconnect from device
  Future<void> disconnectDevice();

  /// Sync data with device
  Future<bool> syncDevice();

  /// Stream of connection status changes
  Stream<DeviceConnection> watchConnectionStatus();
}

/// Mock implementation for development
class MockDeviceRepository implements DeviceRepository {
  DeviceConnection _currentConnection = DeviceConnection(
    isConnected: true,
    lastSyncTime: DateTime.now(),
    deviceName: 'BP Monitor Device',
    connectionType: ConnectionType.bluetooth,
  );

  @override
  Future<DeviceConnection> getConnectionStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentConnection;
  }

  @override
  Future<bool> connectDevice() async {
    await Future.delayed(const Duration(seconds: 2));

    _currentConnection = _currentConnection.copyWith(
      isConnected: true,
      lastSyncTime: DateTime.now(),
    );

    return true;
  }

  @override
  Future<void> disconnectDevice() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentConnection = _currentConnection.copyWith(isConnected: false);
  }

  @override
  Future<bool> syncDevice() async {
    await Future.delayed(const Duration(seconds: 1));

    if (_currentConnection.isConnected) {
      _currentConnection = _currentConnection.copyWith(
        lastSyncTime: DateTime.now(),
      );
      return true;
    }

    return false;
  }

  @override
  Stream<DeviceConnection> watchConnectionStatus() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 10));
      yield _currentConnection;
    }
  }
}
