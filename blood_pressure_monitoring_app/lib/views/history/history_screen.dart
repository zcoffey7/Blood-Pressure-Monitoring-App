import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// History screen for viewing past blood pressure readings
/// Follows SRP - Only responsible for displaying historical data
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                'History',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Text(
                    'Historical data will be displayed here',
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

