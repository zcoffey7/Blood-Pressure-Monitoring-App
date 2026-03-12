import 'package:flutter/material.dart';

/// App-wide color constants with light and dark mode support.
/// Maintains high-contrast accessibility for elderly users.
class AppColors {
  // ── Brand / Accent ──────────────────────────────────────────
  static const Color primary = Color(0xFF3B82F6); // Modern blue
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFDBEAFE);

  // ── Status Colors (shared across themes) ────────────────────
  static const Color normal = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Chart Colors (shared) ───────────────────────────────────
  static const Color systolic = Color(0xFF3B82F6);
  static const Color diastolic = Color(0xFFA855F7);
  static const Color heartRate = Color(0xFF22C55E);

  // ── Connection Status (shared) ──────────────────────────────
  static const Color connected = Color(0xFF22C55E);
  static const Color disconnected = Color(0xFF9CA3AF);

  // ── Light Theme ─────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextHint = Color(0xFF94A3B8);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightInputFill = Color(0xFFF1F5F9);

  // ── Dark Theme ──────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCardBackground = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextHint = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkCardBorder = Color(0xFF334155);
  static const Color darkInputFill = Color(0xFF1E293B);

  // ── Helpers ─────────────────────────────────────────────────
  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color cardBackground(BuildContext context) =>
      Theme.of(context).cardTheme.color ?? lightCardBackground;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? lightTextSecondary
          : darkTextSecondary;

  static Color textHint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? lightTextHint
          : darkTextHint;

  static Color divider(BuildContext context) =>
      Theme.of(context).dividerColor;

  static Color cardBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? lightCardBorder
          : darkCardBorder;

  static Color inputFill(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? lightInputFill
          : darkInputFill;

  static Color shadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0x0A000000)
          : const Color(0x40000000);

  // ── Button colors ───────────────────────────────────────────
  static const Color buttonPrimary = Color(0xFF3B82F6);
  static const Color buttonSecondary = Color(0xFF64748B);
  static const Color buttonDanger = Color(0xFFEF4444);
}
