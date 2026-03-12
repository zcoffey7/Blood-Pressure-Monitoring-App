import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_pressure_monitoring_app/constants/ble_constants.dart';
import 'package:blood_pressure_monitoring_app/models/device_connection.dart';
import 'package:blood_pressure_monitoring_app/models/ppg_packet.dart';
import 'package:blood_pressure_monitoring_app/repositories/ble_device_repository.dart';
import 'package:blood_pressure_monitoring_app/controllers/device_controller.dart';
import 'package:blood_pressure_monitoring_app/services/bluetooth_service.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Build a raw BLE notification payload matching the spec's binary format.
Uint8List buildPpgPayload(int seq, List<int> samples) {
  final length = BleConstants.packetHeaderBytes +
      (BleConstants.sampleBytes * samples.length);
  final bytes = Uint8List(length);
  final view = ByteData.sublistView(bytes);
  view.setUint32(0, seq, Endian.little);
  view.setUint16(4, samples.length, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    view.setUint32(
        BleConstants.packetHeaderBytes + (i * BleConstants.sampleBytes),
        samples[i],
        Endian.little);
  }
  return bytes;
}

// ─── Fake BluetoothService ───────────────────────────────────────────────────

class FakeBluetoothService extends BluetoothService {
  final ppgController = StreamController<PpgPacket>.broadcast();
  final gapCtrl = StreamController<PacketGap>.broadcast();
  final connStateController =
      StreamController<BluetoothConnectionState>.broadcast();

  bool _isConnected = false;

  @override
  Stream<PpgPacket> get ppgStream => ppgController.stream;

  @override
  Stream<PacketGap> get gapStream => gapCtrl.stream;

  @override
  bool get isDeviceConnected => _isConnected;

  @override
  BluetoothDevice? get connectedDevice => _isConnected
      ? BluetoothDevice(
          remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'))
      : null;

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

  void simulatePpgPacket(int seq, List<int> samples) {
    ppgController.add(PpgPacket(packetSeq: seq, samples: samples));
  }

  void simulateGap(int expected, int received) {
    gapCtrl.add(PacketGap(
      expectedSeq: expected,
      receivedSeq: received,
      missedPackets: received - expected,
    ));
  }

  void simulateDisconnect() {
    _isConnected = false;
    connStateController.add(BluetoothConnectionState.disconnected);
  }

  @override
  void dispose() {
    ppgController.close();
    gapCtrl.close();
    connStateController.close();
    super.dispose();
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ════════════════════════════════════════════════════════════════
  // PpgPacket parser
  // ════════════════════════════════════════════════════════════════

  group('PpgPacket.tryParse', () {
    test('parses valid packet from spec example', () {
      // Example from section 4: seq=25, count=3, samples=[1000, 1010, 1020]
      final raw = buildPpgPayload(25, [1000, 1010, 1020]);
      final pkt = PpgPacket.tryParse(raw);

      expect(pkt, isNotNull);
      expect(pkt!.packetSeq, 25);
      expect(pkt.sampleCount, 3);
      expect(pkt.samples, [1000, 1010, 1020]);
    });

    test('parses single-sample packet', () {
      final raw = buildPpgPayload(0, [42]);
      final pkt = PpgPacket.tryParse(raw);

      expect(pkt, isNotNull);
      expect(pkt!.packetSeq, 0);
      expect(pkt.sampleCount, 1);
      expect(pkt.samples, [42]);
    });

    test('parses zero-sample packet', () {
      final raw = buildPpgPayload(99, []);
      final pkt = PpgPacket.tryParse(raw);

      expect(pkt, isNotNull);
      expect(pkt!.packetSeq, 99);
      expect(pkt.sampleCount, 0);
      expect(pkt.samples, isEmpty);
    });

    test('returns null for truncated header', () {
      expect(PpgPacket.tryParse([0x00, 0x00]), isNull);
    });

    test('returns null for length mismatch', () {
      // Header says 3 samples but only 2 × 4 bytes follow
      final raw = buildPpgPayload(1, [100, 200]);
      // Tamper: set sample_count to 3 but keep 2 samples worth of data
      raw[4] = 3;
      expect(PpgPacket.tryParse(raw), isNull);
    });

    test('returns null when sample count exceeds max', () {
      final header = Uint8List(6);
      final view = ByteData.sublistView(header);
      view.setUint32(0, 0, Endian.little);
      view.setUint16(4, 51, Endian.little); // exceeds maxSamplesPerPacket
      expect(PpgPacket.tryParse(header), isNull);
    });
  });

  // ════════════════════════════════════════════════════════════════
  // BLE Constants match the interface spec
  // ════════════════════════════════════════════════════════════════

  group('BleConstants', () {
    test('service UUID matches spec', () {
      expect(
        BleConstants.serviceUuid.toString(),
        'a1f6f5ff-bf33-4d42-9a21-e45dad587e23',
      );
    });

    test('data characteristic UUID matches spec', () {
      expect(
        BleConstants.dataCharUuid.toString(),
        'a1f6f5ff-bf33-4d42-9a21-e45dad587e24',
      );
    });

    test('device name matches spec', () {
      expect(BleConstants.deviceName, 'Sensor-Board');
    });
  });

  // ════════════════════════════════════════════════════════════════
  // DeviceConnection model
  // ════════════════════════════════════════════════════════════════

  group('DeviceConnection model', () {
    test('can be constructed without heartRate', () {
      const conn = DeviceConnection(
        isConnected: true,
        deviceName: 'Sensor-Board',
        connectionType: ConnectionType.bluetooth,
      );

      expect(conn.heartRate, isNull);
      expect(conn.isConnected, true);
    });

    test('copyWith preserves fields', () {
      const original = DeviceConnection(
        isConnected: true,
        deviceName: 'Sensor-Board',
        connectionType: ConnectionType.bluetooth,
      );

      final updated = original.copyWith(isConnected: false);
      expect(updated.isConnected, false);
      expect(updated.deviceName, 'Sensor-Board');
    });
  });

  // ════════════════════════════════════════════════════════════════
  // BleDeviceRepository
  // ════════════════════════════════════════════════════════════════

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
      expect(status.connectionType, ConnectionType.bluetooth);
    });

    test('connectDevice throws when no device selected', () async {
      await expectLater(repo.connectDevice(), throwsException);
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

    test('ppg packets flow through ppgStream', () async {
      final device = BluetoothDevice(
          remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'));
      repo.selectDevice(device);
      await repo.connectDevice();

      final packets = <PpgPacket>[];
      final sub = repo.ppgStream.listen(packets.add);

      fakeBle.simulatePpgPacket(0, [1000, 1010]);
      await Future.delayed(Duration.zero);

      fakeBle.simulatePpgPacket(1, [1020]);
      await Future.delayed(Duration.zero);

      expect(packets.length, 2);
      expect(packets[0].packetSeq, 0);
      expect(packets[0].samples, [1000, 1010]);
      expect(packets[1].packetSeq, 1);

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

  // ════════════════════════════════════════════════════════════════
  // DeviceController — BLE integration
  // ════════════════════════════════════════════════════════════════

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
    });

    test('error is set on connect failure without device selected', () async {
      final success = await controller.connect();
      expect(success, false);
      expect(controller.error, isNotNull);
    });
  });
}
