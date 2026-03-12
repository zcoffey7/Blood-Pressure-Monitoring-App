import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../controllers/ppg_controller.dart';
import '../controllers/device_controller.dart';

class ActionButtons extends StatefulWidget {
  const ActionButtons({super.key});

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  static const int _maxRetryAttempts = 3;
  int _syncRetryCount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(context)),
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
          Expanded(child: _buildPauseButton(context)),
          const SizedBox(width: 12),
          Expanded(child: _buildSyncButton(context)),
        ],
      ),
    );
  }

  Widget _buildPauseButton(BuildContext context) {
    return Selector<PpgController, bool>(
      selector: (_, c) => c.isPaused,
      builder: (context, isPaused, _) {
        final isMonitoring = !isPaused;
        return ElevatedButton.icon(
          onPressed: () => _handlePauseResume(context),
          icon: Icon(isMonitoring ? Icons.pause : Icons.play_arrow, size: 24),
          label: Text(
            isMonitoring ? 'Pause' : 'Resume',
            style: AppTextStyles.button.copyWith(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isMonitoring ? AppColors.buttonPrimary : AppColors.normal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        );
      },
    );
  }

  Widget _buildSyncButton(BuildContext context) {
    return Selector<DeviceController, bool>(
      selector: (_, c) => c.isSyncing,
      builder: (context, isSyncing, _) {
        return OutlinedButton.icon(
          onPressed: isSyncing ? null : () => _handleSync(context),
          icon: isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.buttonSecondary),
                  ),
                )
              : const Icon(Icons.sync, size: 24),
          label: Text(
            isSyncing ? 'Syncing...' : 'Re-Sync',
            style: AppTextStyles.button.copyWith(
              fontSize: 16,
              color: isSyncing
                  ? AppColors.textSecondary(context)
                  : AppColors.buttonSecondary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.buttonSecondary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            side: BorderSide(
              color: isSyncing
                  ? AppColors.textSecondary(context)
                  : AppColors.buttonSecondary,
              width: 1.5,
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePauseResume(BuildContext context) async {
    final ppgController = context.read<PpgController>();
    final isCurrentlyMonitoring = !ppgController.isPaused;

    if (isCurrentlyMonitoring) {
      await ppgController.pause();
    } else {
      await ppgController.resume();
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCurrentlyMonitoring
            ? 'PPG stream paused'
            : 'PPG stream resumed'),
        backgroundColor:
            isCurrentlyMonitoring ? AppColors.warning : AppColors.normal,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleSync(BuildContext context) async {
    final deviceController = context.read<DeviceController>();
    final ppgController = context.read<PpgController>();

    _syncRetryCount++;
    final success = await deviceController.syncDevice();

    if (!context.mounted) return;

    if (success) {
      _syncRetryCount = 0;
      ppgController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Device synced — PPG buffer cleared'),
            ],
          ),
          backgroundColor: AppColors.normal,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      final canRetry = _syncRetryCount < _maxRetryAttempts;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(canRetry
                    ? 'Failed to sync (Attempt $_syncRetryCount/$_maxRetryAttempts)'
                    : 'Failed to sync. Please try again later.'),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
          action: canRetry
              ? SnackBarAction(
                  label: 'RETRY',
                  textColor: Colors.white,
                  onPressed: () => _handleSync(context),
                )
              : null,
        ),
      );

      if (!canRetry) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _syncRetryCount = 0);
        });
      }
    }
  }
}
