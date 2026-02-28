import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../controllers/blood_pressure_controller.dart';
import '../../controllers/device_controller.dart';
import '../../controllers/questionnaire_controller.dart';
import '../../widgets/connection_status_widget.dart';
import '../../widgets/current_reading_card.dart';
import '../../widgets/live_trend_chart.dart';
import '../../widgets/action_buttons.dart';
import '../questionnaire/questionnaire_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _handleRefresh(context),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('Live Monitoring',
                    style: AppTextStyles.heading1
                        .copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: 24),

                const ConnectionStatusWidget(),
                const SizedBox(height: 16),

                _buildErrorBanner(context),

                _buildCheckInButton(context),
                const SizedBox(height: 16),

                const CurrentReadingCard(),
                const SizedBox(height: 24),

                const SizedBox(
                    height: 300,
                    child: RepaintBoundary(child: LiveTrendChart())),
                const SizedBox(height: 16),

                const ActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInButton(BuildContext context) {
    return InkWell(
      onTap: () => _showCheckInSheet(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assignment_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text('Log Check-In',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 18, color: AppColors.textSecondary(context)),
          ],
        ),
      ),
    );
  }

  void _showCheckInSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.cardBackground(context),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Choose Check-In',
                  style: AppTextStyles.heading3.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 16),
              _buildSheetOption(
                context: context,
                parentCtx: ctx,
                templateId: 'symptom_tracker',
                title: 'Symptom Tracker',
                subtitle: 'Log your daily symptoms',
                icon: Icons.assignment_rounded,
                color: const Color(0xFF43A047),
              ),
              const SizedBox(height: 8),
              _buildSheetOption(
                context: context,
                parentCtx: ctx,
                templateId: 'sleep_tracker',
                title: 'Sleep Tracker',
                subtitle: 'Track your sleep quality',
                icon: Icons.bedtime_rounded,
                color: const Color(0xFF5C6BC0),
              ),
              const SizedBox(height: 8),
              _buildSheetOption(
                context: context,
                parentCtx: ctx,
                templateId: 'bp_tracker',
                title: 'Blood Pressure',
                subtitle: 'Record your BP measurements',
                icon: Icons.monitor_heart_rounded,
                color: const Color(0xFFE53935),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required BuildContext context,
    required BuildContext parentCtx,
    required String templateId,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(parentCtx).pop();
        _openTracker(context, templateId);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary(context))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.textSecondary(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    return Consumer<BloodPressureController>(
      builder: (context, controller, _) {
        final error = controller.error;
        if (error == null) return const SizedBox.shrink();

        final userMessage = _sanitizeError(error);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.danger),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    userMessage,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Strip internal exception details from error messages shown to users.
  String _sanitizeError(String error) {
    final colonIdx = error.indexOf(':');
    if (colonIdx > 0 && colonIdx < error.length - 1) {
      final prefix = error.substring(0, colonIdx).trim().toLowerCase();
      if (prefix.contains('failed to') || prefix.contains('error')) {
        return error.substring(0, colonIdx).trim();
      }
    }
    return error;
  }

  Future<void> _handleRefresh(BuildContext context) async {
    final bpController = context.read<BloodPressureController>();
    final deviceController = context.read<DeviceController>();
    await Future.wait([bpController.refresh(), deviceController.refresh()]);
  }

  Future<void> _openTracker(BuildContext context, String templateId) async {
    final controller = context.read<QuestionnaireController>();
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: QuestionnaireScreen(templateId: templateId),
        ),
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                  child: Text('Thank you for completing your check-in!')),
            ],
          ),
          backgroundColor: AppColors.normal,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
