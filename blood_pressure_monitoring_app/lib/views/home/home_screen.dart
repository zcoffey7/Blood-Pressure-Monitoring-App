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

/// Home screen displaying live blood pressure monitoring data
/// Follows SRP - Only responsible for displaying the home view
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                // Header with Settings Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Live Monitoring', style: AppTextStyles.heading1),
                    IconButton(
                      icon: const Icon(
                        Icons.settings_rounded,
                        size: 32,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => _showSettingsInfo(context),
                      tooltip: 'Settings',
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Connection Status Widget
                const ConnectionStatusWidget(),

                const SizedBox(height: 16),

                // Current Reading Card
                const CurrentReadingCard(),

                const SizedBox(height: 24),

                // Live Trend Chart
                const SizedBox(
                  height: 300, // Fixed height for chart
                  child: LiveTrendChart(),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                const ActionButtons(),

                // Bottom padding for better scroll experience
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh(BuildContext context) async {
    final bpController = context.read<BloodPressureController>();
    final deviceController = context.read<DeviceController>();

    // Refresh both controllers
    await Future.wait([bpController.refresh(), deviceController.refresh()]);
  }

  /// Show settings info (placeholder for future settings screen)
  void _showSettingsInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Settings screen coming soon!',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
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
}
