import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// Home screen displaying live blood pressure monitoring data
/// Follows SRP - Only responsible for displaying the home view
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              // Header
              Text(
                'Live Monitoring',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 24),
              
              // Placeholder for connection status (Commit 2)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Connection Status Widget'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Placeholder for current reading card (Commit 2)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.cardBorder,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text('Current Reading Card'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Placeholder for live trend chart (Commit 3)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Live Trend Chart'),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Placeholder for action buttons (Commit 4)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Action Buttons'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

