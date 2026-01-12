import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../controllers/blood_pressure_controller.dart';
import '../controllers/device_controller.dart';

/// Widget displaying action buttons for monitoring control
/// Follows SRP - Only responsible for displaying action buttons
class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pause/Resume Monitoring Button
          Expanded(child: _buildPauseButton(context)),

          const SizedBox(width: 12),

          // Re-Sync Device Button
          Expanded(child: _buildSyncButton(context)),
        ],
      ),
    );
  }

  Widget _buildPauseButton(BuildContext context) {
    final bpController = context.watch<BloodPressureController>();
    final isMonitoring = !bpController.isPaused;

    return ElevatedButton.icon(
      onPressed: () => _handlePauseResume(context),
      icon: Icon(isMonitoring ? Icons.pause : Icons.play_arrow, size: 24),
      label: Text(
        isMonitoring ? 'Pause Monitoring' : 'Resume Monitoring',
        style: AppTextStyles.button.copyWith(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isMonitoring
            ? AppColors.buttonPrimary
            : AppColors.normal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context) {
    final deviceController = context.watch<DeviceController>();
    final isSyncing = deviceController.isSyncing;

    return OutlinedButton.icon(
      onPressed: isSyncing ? null : () => _handleSync(context),
      icon: isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.buttonSecondary,
                ),
              ),
            )
          : const Icon(Icons.sync, size: 24),
      label: Text(
        isSyncing ? 'Syncing...' : 'Re-Sync Device',
        style: AppTextStyles.button.copyWith(
          fontSize: 16,
          color: isSyncing
              ? AppColors.textSecondary
              : AppColors.buttonSecondary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.buttonSecondary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(
          color: isSyncing
              ? AppColors.textSecondary
              : AppColors.buttonSecondary,
          width: 2,
        ),
      ),
    );
  }

  void _handlePauseResume(BuildContext context) {
    final bpController = context.read<BloodPressureController>();
    final isCurrentlyMonitoring = !bpController.isPaused;

    if (isCurrentlyMonitoring) {
      // Pause monitoring
      bpController.pauseMonitoring();
    } else {
      // Resume monitoring
      bpController.resumeMonitoring();
    }

    final message = isCurrentlyMonitoring
        ? 'Monitoring paused - Data updates stopped'
        : 'Monitoring resumed - Data updates active';

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: isCurrentlyMonitoring
            ? AppColors.warning
            : AppColors.normal,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleSync(BuildContext context) async {
    final deviceController = context.read<DeviceController>();
    final bpController = context.read<BloodPressureController>();

    // Attempt to sync with device
    final success = await deviceController.syncDevice();

    if (!context.mounted) return;

    if (success) {
      // Refresh blood pressure data after successful sync
      await bpController.refresh();

      if (!context.mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Device synced successfully',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.normal,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Failed to sync device',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'RETRY',
            textColor: Colors.white,
            onPressed: () => _handleSync(context),
          ),
        ),
      );
    }
  }
}
