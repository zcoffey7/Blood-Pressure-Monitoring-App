import 'package:flutter/material.dart';
import '../../constants/app_text_styles.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alerts',
                  style: AppTextStyles.heading1
                      .copyWith(color: colorScheme.onSurface)),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Text('System alerts will be displayed here',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: colorScheme.onSurface),
                      textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
