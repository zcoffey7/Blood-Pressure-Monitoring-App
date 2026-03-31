import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../controllers/device_controller.dart';

/// Hold-to-activate pump button.
/// Press and hold sends pump ON; releasing sends pump OFF.
/// Only visible when connected and the command characteristic exists.
class PumpControlWidget extends StatelessWidget {
  const PumpControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceController>(
      builder: (context, controller, _) {
        if (!controller.isConnected || !controller.hasPumpControl) {
          return const SizedBox.shrink();
        }

        final isOn = controller.isPumpOn;

        return GestureDetector(
          onTapDown: (_) => controller.setPump(true),
          onTapUp: (_) => controller.setPump(false),
          onTapCancel: () => controller.setPump(false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isOn
                  ? AppColors.normal.withValues(alpha: 0.12)
                  : AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOn ? AppColors.normal : AppColors.cardBorder(context),
                width: isOn ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow(context),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isOn ? AppColors.normal : AppColors.disconnected)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.air_rounded,
                    color: isOn ? AppColors.normal : AppColors.disconnected,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compression Pump',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOn ? 'Running — release to stop' : 'Hold to activate',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isOn
                              ? AppColors.normal
                              : AppColors.textSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOn ? AppColors.normal : AppColors.disconnected,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
