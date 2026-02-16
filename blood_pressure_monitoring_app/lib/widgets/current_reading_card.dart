import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../controllers/blood_pressure_controller.dart';
import '../models/blood_pressure_reading.dart';
import '../utils/blood_pressure_status.dart';

class CurrentReadingCard extends StatelessWidget {
  const CurrentReadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BloodPressureController>(
      builder: (context, controller, child) {
        final reading = controller.currentReading;

        if (controller.isLoading && reading == null) {
          return _buildShell(context, child: const Center(child: CircularProgressIndicator()));
        }

        if (reading == null) {
          return _buildShell(context,
              child: Center(
                child: Text('No data available',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textSecondary(context))),
              ));
        }

        return _buildShell(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: AppColors.danger, size: 24),
                  const SizedBox(width: 8),
                  Text('Current Reading',
                      style: AppTextStyles.heading3
                          .copyWith(color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBPValue(context,
                      value: reading.systolic,
                      label: 'Systolic',
                      color: AppColors.systolic),
                  Container(
                      height: 80,
                      width: 1,
                      color: AppColors.divider(context)),
                  _buildBPValue(context,
                      value: reading.diastolic,
                      label: 'Diastolic',
                      color: AppColors.diastolic),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text('${reading.heartRate}',
                        style: AppTextStyles.heartRateValue
                            .copyWith(color: AppColors.heartRate)),
                    const SizedBox(height: 4),
                    Text('Heart Rate (BPM)',
                        style: AppTextStyles.bpLabel
                            .copyWith(color: AppColors.textSecondary(context))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(child: _buildStatusBadge(reading.status)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShell(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBPValue(BuildContext context,
      {required int value, required String label, required Color color}) {
    return Column(
      children: [
        Text('$value', style: AppTextStyles.bpValue.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.bpLabel
                .copyWith(color: AppColors.textSecondary(context))),
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
}
