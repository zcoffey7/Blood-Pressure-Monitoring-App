import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// Alerts screen for displaying blood pressure alerts and notifications
/// Follows SRP - Only responsible for displaying alerts
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alerts',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Text(
                    'System alerts will be displayed here',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

