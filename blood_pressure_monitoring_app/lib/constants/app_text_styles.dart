import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App-wide text styles optimized for elderly users
/// Following accessibility guidelines with large, readable fonts
class AppTextStyles {
  // Large Headers - For main headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  // Blood Pressure Reading Values - Extra large for visibility
  static const TextStyle bpValue = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
  );
  
  static const TextStyle bpLabel = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  
  // Heart Rate
  static const TextStyle heartRateValue = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.heartRate,
    height: 1.0,
  );
  
  // Status Text
  static const TextStyle statusNormal = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.normal,
    height: 1.2,
  );
  
  static const TextStyle statusWarning = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.warning,
    height: 1.2,
  );
  
  static const TextStyle statusDanger = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.danger,
    height: 1.2,
  );
  
  // Body Text - Larger than standard for readability
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );
  
  // Navigation Labels
  static const TextStyle navLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.2,
  );
  
  static const TextStyle navLabelActive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1.2,
  );
  
  // Connection Status
  static const TextStyle connectionStatus = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );
}

