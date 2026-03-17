import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/feature_flags.dart';
import '../controllers/ppg_controller.dart';

class CurrentReadingCard extends StatelessWidget {
  const CurrentReadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PpgController>(
      builder: (context, controller, child) {
        if (!controller.hasData) {
          return _buildShell(context,
              child: Center(
                child: Text('Waiting for PPG data…',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textSecondary(context))),
              ));
        }

        return _buildShell(
          context,
          child: Row(
            children: [
              const Icon(
                FeatureFlags.enableDsp
                    ? Icons.favorite_rounded
                    : Icons.sensors_rounded,
                color: FeatureFlags.enableDsp
                    ? AppColors.heartRate
                    : AppColors.primary,
                size: 36,
              ),
              const SizedBox(width: 16),
              if (FeatureFlags.enableDsp)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.heartRateBpm != null
                            ? '${controller.heartRateBpm} BPM'
                            : '-- BPM',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.heartRate,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('Heart Rate',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary(context))),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Text('PPG Sensor',
                      style: AppTextStyles.heading3.copyWith(
                          color: Theme.of(context).colorScheme.onSurface)),
                ),
              if (!controller.isPaused) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.connected.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.connected,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('LIVE',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.connected,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ],
              if (controller.gapCount > 0) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: '${controller.gapCount} packet(s) dropped',
                  child: const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 22),
                ),
              ],
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
}
