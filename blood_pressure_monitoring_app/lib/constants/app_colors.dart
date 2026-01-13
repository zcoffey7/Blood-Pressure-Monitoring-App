import 'package:flutter/material.dart';

/// App-wide color constants following high-contrast accessibility guidelines
/// for elderly users with potential vision impairments.
class AppColors {
  // Primary Colors - High contrast for readability
  static const Color primary = Color(0xFF2196F3); // Bright blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  // Background Colors
  static const Color background = Color(0xFFFFFFFF); // Pure white
  static const Color cardBackground = Color(0xFFF5F5F5); // Light gray
  
  // Text Colors - High contrast
  static const Color textPrimary = Color(0xFF000000); // Pure black
  static const Color textSecondary = Color(0xFF424242); // Dark gray
  static const Color textHint = Color(0xFF757575); // Medium gray
  
  // Status Colors - Health indicators
  static const Color normal = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color danger = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue
  
  // Blood Pressure Chart Colors
  static const Color systolic = Color(0xFF2196F3); // Blue for systolic
  static const Color diastolic = Color(0xFF9C27B0); // Purple for diastolic
  static const Color heartRate = Color(0xFF4CAF50); // Green for heart rate
  
  // UI Element Colors
  static const Color cardBorder = Color(0xFF4CAF50); // Green border
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFFF44336); // Red for critical actions
  static const Color buttonSecondary = Color(0xFF2196F3); // Blue for secondary actions
  
  // Connection Status
  static const Color connected = Color(0xFF4CAF50); // Green
  static const Color disconnected = Color(0xFF9E9E9E); // Gray
  static const Color batteryHigh = Color(0xFF4CAF50); // Green
  static const Color batteryMedium = Color(0xFFFF9800); // Orange
  static const Color batteryLow = Color(0xFFF44336); // Red
}

