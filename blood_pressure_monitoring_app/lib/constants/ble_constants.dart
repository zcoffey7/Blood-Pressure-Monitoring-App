import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE UUIDs and configuration for the ESP32 PPG sensor board.
/// Values sourced from ble_ppg_streaming_interface_spec.pdf.
class BleConstants {
  BleConstants._();

  // ── Service & Characteristic UUIDs ─────────────────────────────
  static final Guid serviceUuid = Guid('a1f6f5ff-bf33-4d42-9a21-e45dad587e23');

  static final Guid dataCharUuid = Guid('a1f6f5ff-bf33-4d42-9a21-e45dad587e24');

  static final Guid cmdCharUuid = Guid('a1f6f5ff-bf33-4d42-9a21-e45dad587e25');

  // ── Pump Commands ─────────────────────────────────────────────
  static const int pumpOff = 0x00;
  static const int pumpOn = 0x01;

  // ── Device Discovery ──────────────────────────────────────────
  static const String deviceName = 'Sensor-Board';

  // ── Scan Configuration ─────────────────────────────────────────
  static const Duration scanTimeout = Duration(seconds: 15);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // ── Reconnect Configuration ────────────────────────────────────
  static const int maxReconnectAttempts = 3;
  static const Duration reconnectDelay = Duration(seconds: 2);

  // ── PPG Packet Format ──────────────────────────────────────────
  static const int packetHeaderBytes = 6; // 4 (seq) + 2 (count)
  static const int sampleBytes = 4; // uint32 per sample
  static const int maxSamplesPerPacket = 50;
  static const int ppgBitMask = 0x3FFFF; // lower 18 bits meaningful

  // ── PPG Sampling ────────────────────────────────────────────────
  static const double ppgSampleRateHz = 100.0;
}
