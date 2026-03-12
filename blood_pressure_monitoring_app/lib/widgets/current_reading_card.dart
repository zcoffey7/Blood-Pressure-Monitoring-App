import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sensors_rounded,
                      color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text('PPG Sensor Data',
                      style: AppTextStyles.heading3.copyWith(
                          color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  if (!controller.isPaused) ...[
                    Text('LIVE',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.connected,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.connected,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(
                    context,
                    value: '${controller.latestValue ?? 0}',
                    label: 'Latest Sample',
                    color: AppColors.primary,
                  ),
                  Container(
                      height: 60,
                      width: 1,
                      color: AppColors.divider(context)),
                  _buildStatColumn(
                    context,
                    value: '${controller.packetCount}',
                    label: 'Packets',
                    color: AppColors.systolic,
                  ),
                  Container(
                      height: 60,
                      width: 1,
                      color: AppColors.divider(context)),
                  _buildStatColumn(
                    context,
                    value: '${controller.totalSampleCount}',
                    label: 'Samples',
                    color: AppColors.diastolic,
                  ),
                ],
              ),
              if (controller.gapCount > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.gapCount} packet(s) dropped',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.warning),
                      ),
                    ],
                  ),
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

  Widget _buildStatColumn(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary(context))),
      ],
    );
  }
}
