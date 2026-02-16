import 'package:flutter/material.dart';

/// App-wide text styles optimized for elderly users.
/// Colors are NOT hardcoded — use Theme.of(context) or pass colors explicitly.
class AppTextStyles {
  // ── Headings ────────────────────────────────────────────────
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ── Blood Pressure Values ───────────────────────────────────
  static const TextStyle bpValue = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  static const TextStyle bpLabel = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // ── Heart Rate ──────────────────────────────────────────────
  static const TextStyle heartRateValue = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  // ── Status ──────────────────────────────────────────────────
  static TextStyle statusNormal = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF22C55E),
    height: 1.2,
  );

  static TextStyle statusWarning = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFFF59E0B),
    height: 1.2,
  );

  static TextStyle statusDanger = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFFEF4444),
    height: 1.2,
  );

  // ── Body ────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // ── Button ──────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  // ── Navigation ──────────────────────────────────────────────
  static const TextStyle navLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle navLabelActive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  // ── Connection Status ───────────────────────────────────────
  static const TextStyle connectionStatus = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
