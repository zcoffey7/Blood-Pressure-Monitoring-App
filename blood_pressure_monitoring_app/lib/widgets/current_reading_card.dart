import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../controllers/blood_pressure_controller.dart';
import '../models/blood_pressure_reading.dart';
import '../utils/blood_pressure_status.dart';

/// Widget displaying current blood pressure reading
/// Follows SRP - Only responsible for displaying current BP data
class CurrentReadingCard extends StatelessWidget {
  const CurrentReadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BloodPressureController>(
      builder: (context, controller, child) {
        final reading = controller.currentReading;

        if (controller.isLoading && reading == null) {
          return _buildLoadingState();
        }

        if (reading == null) {
          return _buildNoDataState();
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Title
              Row(
                children: [
                  const Icon(Icons.favorite, color: AppColors.danger, size: 24),
                  const SizedBox(width: 8),
                  Text('Current Reading', style: AppTextStyles.heading3),
                ],
              ),

              const SizedBox(height: 24),

              // BP Values Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Systolic
                  _buildBPValue(
                    value: reading.systolic,
                    label: 'Systolic',
                    color: AppColors.systolic,
                  ),

                  // Vertical Divider
                  Container(height: 80, width: 2, color: AppColors.divider),

                  // Diastolic
                  _buildBPValue(
                    value: reading.diastolic,
                    label: 'Diastolic',
                    color: AppColors.diastolic,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Heart Rate
              Center(
                child: Column(
                  children: [
                    Text(
                      '${reading.heartRate}',
                      style: AppTextStyles.heartRateValue,
                    ),
                    const SizedBox(height: 4),
                    Text('Heart Rate (BPM)', style: AppTextStyles.bpLabel),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status Badge
              Center(child: _buildStatusBadge(reading.status)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBPValue({
    required int value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text('$value', style: AppTextStyles.bpValue.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bpLabel),
      ],
    );
  }

  Widget _buildStatusBadge(BloodPressureStatus status) {
    Color backgroundColor;
    TextStyle textStyle;

    switch (status) {
      case BloodPressureStatus.low:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textStyle = AppTextStyles.statusWarning;
        break;
      case BloodPressureStatus.normal:
        backgroundColor = AppColors.normal.withValues(alpha: 0.1);
        textStyle = AppTextStyles.statusNormal;
        break;
      case BloodPressureStatus.elevated:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textStyle = AppTextStyles.statusWarning;
        break;
      case BloodPressureStatus.high:
        backgroundColor = AppColors.danger.withValues(alpha: 0.1);
        textStyle = AppTextStyles.statusDanger;
        break;
      case BloodPressureStatus.critical:
        backgroundColor = AppColors.danger.withValues(alpha: 0.2);
        textStyle = AppTextStyles.statusDanger;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        BloodPressureStatusUtil.getSimpleStatus(status),
        style: textStyle,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Center(
        child: Text(
          'No data available',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
