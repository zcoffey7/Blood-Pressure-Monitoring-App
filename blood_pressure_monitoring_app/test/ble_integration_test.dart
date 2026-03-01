import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_pressure_monitoring_app/models/device_connection.dart';
import 'package:blood_pressure_monitoring_app/repositories/ble_device_repository.dart';
import 'package:blood_pressure_monitoring_app/controllers/device_controller.dart';
import 'package:blood_pressure_monitoring_app/services/bluetooth_service.dart';

// ─── Fake BluetoothService ───────────────────────────────────────────────────
// Replaces real BLE calls with controllable streams for testing.

class FakeBluetoothService extends BluetoothService {
  final hrController = StreamController<int>.broadcast();
  final batteryController = StreamController<int>.broadcast();
  final connStateController =
      StreamController<BluetoothConnectionState>.broadcast();

  bool _isConnected = false;

  @override
  Stream<int> get heartRateStream => hrController.stream;

  @override
  Stream<int> get batteryLevelStream => batteryController.stream;

  @override
  bool get isDeviceConnected => _isConnected;

  @override
  BluetoothDevice? get connectedDevice =>
      _isConnected ? BluetoothDevice(remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF')) : null;

  @override
  Stream<BluetoothConnectionState> get connectionState =>
      connStateController.stream;

  @override
  Future<void> connect(BluetoothDevice device) async {
    _isConnected = true;
    connStateController.add(BluetoothConnectionState.connected);
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    connStateController.add(BluetoothConnectionState.disconnected);
  }

  void simulateHeartRate(int bpm) => hrController.add(bpm);
  void simulateBattery(int level) => batteryController.add(level);

  void simulateDisconnect() {
    _isConnected = false;
    connStateController.add(BluetoothConnectionState.disconnected);
  }

  @override
  void dispose() {
    hrController.close();
    batteryController.close();
    connStateController.close();
    super.dispose();
  }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ══════════════════════════════════════════════════════════════
  // DeviceConnection model — heartRate field
  // ══════════════════════════════════════════════════════════════

  group('DeviceConnection model', () {
    test('includes heartRate in constructor and getters', () {
      const conn = DeviceConnection(
        isConnected: true,
        batteryLevel: 85,
        heartRate: 72,
        deviceName: 'Test',
        connectionType: ConnectionType.bluetooth,
      );

      expect(conn.heartRate, 72);
      expect(conn.batteryLevel, 85);
      expect(conn.isConnected, true);
    });

    test('heartRate defaults to null when omitted', () {
      const conn = DeviceConnection(
        isConnected: false,
        batteryLevel: 50,
        deviceName: 'Test',
        connectionType: ConnectionType.bluetooth,
      );

      expect(conn.heartRate, isNull);
    });

    test('copyWith preserves heartRate', () {
      const original = DeviceConnection(
        isConnected: true,
        batteryLevel: 80,
        heartRate: 65,
        deviceName: 'Device',
        connectionType: ConnectionType.bluetooth,
      );

      final updated = original.copyWith(batteryLevel: 70);
      expect(updated.heartRate, 65);
      expect(updated.batteryLevel, 70);
    });

    test('copyWith updates heartRate', () {
      const original = DeviceConnection(
        isConnected: true,
        batteryLevel: 80,
        heartRate: 65,
        deviceName: 'Device',
        connectionType: ConnectionType.bluetooth,
      );

      final updated = original.copyWith(heartRate: 90);
      expect(updated.heartRate, 90);
      expect(updated.batteryLevel, 80);
    });

    test('toJson includes heartRate', () {
      const conn = DeviceConnection(
        isConnected: true,
        batteryLevel: 80,
        heartRate: 72,
        deviceName: 'Device',
        connectionType: ConnectionType.bluetooth,
      );

      final json = conn.toJson();
      expect(json['heartRate'], 72);
    });

    test('fromJson parses heartRate', () {
      final json = {
        'isConnected': true,
        'batteryLevel': 90,
        'heartRate': 68,
        'deviceName': 'Test',
        'connectionType': 'bluetooth',
      };

      final conn = DeviceConnection.fromJson(json);
      expect(conn.heartRate, 68);
    });

    test('fromJson handles null heartRate', () {
      final json = {
        'isConnected': true,
        'batteryLevel': 90,
        'heartRate': null,
        'deviceName': 'Test',
        'connectionType': 'bluetooth',
      };

      final conn = DeviceConnection.fromJson(json);
      expect(conn.heartRate, isNull);
    });

    test('equality includes heartRate', () {
      const a = DeviceConnection(
        isConnected: true,
        batteryLevel: 80,
        heartRate: 72,
        deviceName: 'D',
        connectionType: ConnectionType.bluetooth,
      );
      const b = DeviceConnection(
        isConnected: true,
        batteryLevel: 80,
        heartRate: 72,
        deviceName: 'D',
        connectionType: ConnectionType.bluetooth,
      );
      const c = DeviceConnection(
        isConnected: true,
        batteryLevel: 80,
        heartRate: 90,
        deviceName: 'D',
        connectionType: ConnectionType.bluetooth,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ══════════════════════════════════════════════════════════════
  // BleDeviceRepository — connection & data streaming
  // ══════════════════════════════════════════════════════════════

  group('BleDeviceRepository', () {
    late FakeBluetoothService fakeBle;
    late BleDeviceRepository repo;

    setUp(() {
      fakeBle = FakeBluetoothService();
      repo = BleDeviceRepository(fakeBle);
    });

    tearDown(() {
      repo.dispose();
    });

    test('getConnectionStatus returns disconnected initially', () async {
      final status = await repo.getConnectionStatus();
      expect(status.isConnected, false);
      expect(status.heartRate, isNull);
      expect(status.connectionType, ConnectionType.bluetooth);
    });

    test('connectDevice throws when no device selected', () async {
      expect(() => repo.connectDevice(), throwsException);
    });

    test('connectDevice succeeds after selectDevice', () async {
      final device = BluetoothDevice(
          remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'));
      repo.selectDevice(device);

      final success = await repo.connectDevice();
      expect(success, true);

      final status = await repo.getConnectionStatus();
      expect(status.isConnected, true);
    });

    test('heart rate updates flow through watchConnectionStatus', () async {
      final device = BluetoothDevice(
          remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'));
      repo.selectDevice(device);
      await repo.connectDevice();

      final updates = <DeviceConnection>[];
      final sub = repo.watchConnectionStatus().listen(updates.add);

      // Allow the initial status emission from connectDevice
      await Future.delayed(Duration.zero);

      fakeBle.simulateHeartRate(72);
      await Future.delayed(Duration.zero);

      fakeBle.simulateHeartRate(75);
      await Future.delayed(Duration.zero);

      expect(updates.any((u) => u.heartRate == 72), true);
      expect(updates.any((u) => u.heartRate == 75), true);

      await sub.cancel();
    });

    test('battery updates flow through watchConnectionStatus', () async {
      final device = BluetoothDevice(
          remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'));
      repo.selectDevice(device);
      await repo.connectDevice();

      final updates = <DeviceConnection>[];
      final sub = repo.watchConnectionStatus().listen(updates.add);

      await Future.delayed(Duration.zero);

      fakeBle.simulateBattery(85);
      await Future.delayed(Duration.zero);

      expect(updates.any((u) => u.batteryLevel == 85), true);

      await sub.cancel();
    });

    test('disconnectDevice resets state', () async {
      final device = BluetoothDevice(
          remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'));
      repo.selectDevice(device);
      await repo.connectDevice();
      await repo.disconnectDevice();

      final status = await repo.getConnectionStatus();
      expect(status.isConnected, false);
      expect(status.heartRate, isNull);
      expect(status.batteryLevel, 0);
    });

    test('syncDevice returns true when connected', () async {
      final device = BluetoothDevice(
          remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'));
      repo.selectDevice(device);
      await repo.connectDevice();

      expect(await repo.syncDevice(), true);
    });

    test('syncDevice returns false when disconnected', () async {
      expect(await repo.syncDevice(), false);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // DeviceController — BLE integration
  // ══════════════════════════════════════════════════════════════

  group('DeviceController with BleDeviceRepository', () {
    late FakeBluetoothService fakeBle;
    late BleDeviceRepository repo;
    late DeviceController controller;

    setUp(() {
      fakeBle = FakeBluetoothService();
      repo = BleDeviceRepository(fakeBle);
      controller = DeviceController(repo, enableMonitoring: false);
    });

    tearDown(() {
      controller.dispose();
      repo.dispose();
    });

    test('canScan returns true for BleDeviceRepository', () {
      expect(controller.canScan, true);
    });

    test('heartRate is null when disconnected', () async {
      await controller.loadConnectionStatus();
      expect(controller.heartRate, isNull);
    });

    test('connect updates isConnected', () async {
      final device = BluetoothDevice(
          remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'));
      controller.selectDevice(device);

      final success = await controller.connect();
      expect(success, true);
      expect(controller.isConnected, true);
    });

    test('disconnect updates state', () async {
      final device = BluetoothDevice(
          remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'));
      controller.selectDevice(device);
      await controller.connect();
      await controller.disconnect();

      expect(controller.isConnected, false);
      expect(controller.heartRate, isNull);
    });

    test('heart rate updates reach controller via monitoring', () async {
      final device = BluetoothDevice(
          remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'));

      // Enable monitoring for this test
      final monitoredController = DeviceController(repo, enableMonitoring: true);
      monitoredController.selectDevice(device);
      await monitoredController.connect();

      fakeBle.simulateHeartRate(80);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(monitoredController.heartRate, 80);

      monitoredController.dispose();
    });

    test('error is set on connect failure without device selected', () async {
      final success = await controller.connect();
      expect(success, false);
      expect(controller.error, isNotNull);
    });
  });
}
