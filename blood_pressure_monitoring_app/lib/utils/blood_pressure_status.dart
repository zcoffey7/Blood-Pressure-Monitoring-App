import '../models/blood_pressure_reading.dart';

/// Utility class for determining blood pressure status
/// Based on American Heart Association guidelines
/// Follows SRP - Only responsible for BP classification logic
class BloodPressureStatusUtil {
  /// Determine blood pressure status from systolic and diastolic values
  ///
  /// Guidelines (mmHg):
  /// - Low: Systolic < 90 OR Diastolic < 60
  /// - Normal: Systolic < 120 AND Diastolic < 80
  /// - Elevated: Systolic 120-129 AND Diastolic < 80
  /// - High: Systolic 130-139 OR Diastolic 80-89
  /// - Critical: Systolic >= 140 OR Diastolic >= 90
  static BloodPressureStatus getStatus(int systolic, int diastolic) {
    // Hypotension (Low BP)
    if (systolic < 90 || diastolic < 60) {
      return BloodPressureStatus.low;
    }

    // Hypertensive Crisis (Critical)
    if (systolic >= 140 || diastolic >= 90) {
      return BloodPressureStatus.critical;
    }

    // Hypertension Stage 1 (High)
    if (systolic >= 130 || diastolic >= 80) {
      return BloodPressureStatus.high;
    }

    // Elevated
    if (systolic >= 120 && systolic < 130 && diastolic < 80) {
      return BloodPressureStatus.elevated;
    }

    // Normal
    return BloodPressureStatus.normal;
  }

  /// Get user-friendly description of BP status
  static String getStatusDescription(BloodPressureStatus status) {
    switch (status) {
      case BloodPressureStatus.low:
        return 'Low - Hypotension';
      case BloodPressureStatus.normal:
        return 'Normal';
      case BloodPressureStatus.elevated:
        return 'Elevated';
      case BloodPressureStatus.high:
        return 'High - Stage 1';
      case BloodPressureStatus.critical:
        return 'Critical - Seek Help';
    }
  }

  /// Get simple status text for display
  static String getSimpleStatus(BloodPressureStatus status) {
    switch (status) {
      case BloodPressureStatus.low:
        return 'Low';
      case BloodPressureStatus.normal:
        return 'Normal';
      case BloodPressureStatus.elevated:
        return 'Elevated';
      case BloodPressureStatus.high:
        return 'High';
      case BloodPressureStatus.critical:
        return 'Critical';
    }
  }

  /// Check if medical attention is recommended
  static bool requiresMedicalAttention(BloodPressureStatus status) {
    return status == BloodPressureStatus.critical ||
        status == BloodPressureStatus.low;
  }
}
