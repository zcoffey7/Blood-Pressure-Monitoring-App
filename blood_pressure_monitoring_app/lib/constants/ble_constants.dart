import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE UUIDs and configuration for the ESP32 blood pressure monitor.
/// Update these to match your ESP32 firmware.
class BleConstants {
  BleConstants._();

  // ── Service & Characteristic UUIDs ─────────────────────────────
  static final Guid serviceUuid =
      Guid('4fafc201-1fb5-459e-8fcc-c5c9c331914b');

  static final Guid heartRateCharUuid =
      Guid('beb5483e-36e1-4688-b7f5-ea07361b26a8');

  static final Guid batteryLevelCharUuid =
      Guid('d5875ac1-e317-4b9e-b49a-70a05821e6a1');

  // ── Scan Configuration ─────────────────────────────────────────
  static const String deviceNamePrefix = 'BP-Monitor';
  static const Duration scanTimeout = Duration(seconds: 15);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // ── Reconnect Configuration ────────────────────────────────────
  static const int maxReconnectAttempts = 3;
  static const Duration reconnectDelay = Duration(seconds: 2);
}
