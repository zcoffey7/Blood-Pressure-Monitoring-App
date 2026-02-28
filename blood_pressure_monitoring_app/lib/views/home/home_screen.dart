import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../controllers/blood_pressure_controller.dart';
import '../../controllers/device_controller.dart';
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Live Monitoring',
                        style: AppTextStyles.heading1
                            .copyWith(color: colorScheme.onSurface)),
                    IconButton(
                      icon: Icon(Icons.settings_rounded,
                          size: 32, color: colorScheme.onSurface),
                      onPressed: () => _showSettingsInfo(context),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const ConnectionStatusWidget(),
                const SizedBox(height: 16),

                // Symptom Tracker — full-width, highest priority
                _buildTrackerCard(
                  context,
                  templateId: 'symptom_tracker',
                  title: 'Symptom Tracker',
                  subtitle: 'Log your daily symptoms',
                  icon: Icons.assignment_rounded,
                  gradientColors: [const Color(0xFF43A047), const Color(0xFF66BB6A)],
                ),
                const SizedBox(height: 12),

                // Sleep + BP side by side
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallTrackerCard(
                        context,
                        templateId: 'sleep_tracker',
                        title: 'Sleep',
                        icon: Icons.bedtime_rounded,
                        gradientColors: [const Color(0xFF5C6BC0), const Color(0xFF7986CB)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallTrackerCard(
                        context,
                        templateId: 'bp_tracker',
                        title: 'Blood Pressure',
                        icon: Icons.monitor_heart_rounded,
                        gradientColors: [const Color(0xFFE53935), const Color(0xFFEF5350)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Vital Chips ───────────────────────────────
                _buildVitalChips(context),
                const SizedBox(height: 16),

                const CurrentReadingCard(),
                const SizedBox(height: 24),

                const SizedBox(height: 300, child: LiveTrendChart()),
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

  Widget _buildTrackerCard(
    BuildContext context, {
    required String templateId,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? gradientColors.map((c) => Color.lerp(c, Colors.black, 0.25)!).toList()
        : gradientColors;

    return InkWell(
      onTap: () => _openTracker(context, templateId),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.heading3
                          .copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTrackerCard(
    BuildContext context, {
    required String templateId,
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? gradientColors.map((c) => Color.lerp(c, Colors.black, 0.25)!).toList()
        : gradientColors;

    return InkWell(
      onTap: () => _openTracker(context, templateId),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 8),
            Text(title,
                style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalChips(BuildContext context) {
    return Consumer<BloodPressureController>(
      builder: (context, controller, _) {
        final reading = controller.currentReading;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final chipBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        final borderColor = AppColors.cardBorder(context);

        return Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.speed_rounded,
                        size: 20, color: AppColors.systolic),
                    const SizedBox(width: 8),
                    Text(
                      reading != null
                          ? '${reading.systolic}/${reading.diastolic} mmHg'
                          : '-- / -- mmHg',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_rounded,
                        size: 20, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Text(
                      reading != null
                          ? '${reading.heartRate} BPM'
                          : '-- BPM',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRefresh(BuildContext context) async {
    final bpController = context.read<BloodPressureController>();
    final deviceController = context.read<DeviceController>();
    await Future.wait([bpController.refresh(), deviceController.refresh()]);
  }

  void _showSettingsInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('Settings screen coming soon!')),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _openTracker(BuildContext context, String templateId) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            QuestionnaireScreen(templateId: templateId),
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
