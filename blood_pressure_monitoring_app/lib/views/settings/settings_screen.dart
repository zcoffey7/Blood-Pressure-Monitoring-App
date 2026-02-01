import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../services/notification_service.dart';
import '../../controllers/auth_controller.dart';

/// Settings screen for app configuration
/// Follows SRP - Only responsible for displaying settings
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notificationService = NotificationService();
  bool _notificationsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    // Check both permissions and if reminder is actually scheduled
    final hasPermissions = await _notificationService.areNotificationsEnabled();
    final isScheduled = await _notificationService.isDailyReminderScheduled();
    
    setState(() {
      _notificationsEnabled = hasPermissions && isScheduled;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTextStyles.heading1),
              const SizedBox(height: 24),

              // Account Section
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  return _buildSectionCard(
                    title: 'Account',
                    icon: Icons.person_rounded,
                    children: [
                      _buildSettingTile(
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: authController.userEmail ?? 'Not available',
                      ),
                      const Divider(),
                      _buildSettingTile(
                        icon: Icons.badge,
                        title: 'Display Name',
                        subtitle: authController.userDisplayName ?? 'Not set',
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton.icon(
                          onPressed: () => _handleSignOut(context),
                          icon: const Icon(Icons.logout, size: 24),
                          label: const Text('Sign Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Notifications Section
              _buildSectionCard(
                title: 'Notifications',
                icon: Icons.notifications_rounded,
                children: [
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    _buildSettingTile(
                      icon: Icons.alarm,
                      title: 'Daily Reminder',
                      subtitle: '7:00 PM daily check-in',
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) => _toggleNotifications(value),
                        activeTrackColor: AppColors.normal,
                      ),
                    ),
                    const Divider(),
                    _buildSettingTile(
                      icon: Icons.info_outline,
                      title: 'Notification Status',
                      subtitle: _notificationsEnabled
                          ? 'Notifications are enabled'
                          : 'Notifications are disabled',
                      trailing: Icon(
                        _notificationsEnabled
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _notificationsEnabled
                            ? AppColors.normal
                            : AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // About Section
              _buildSectionCard(
                title: 'About',
                icon: Icons.info_rounded,
                children: [
                  _buildSettingTile(
                    icon: Icons.medical_services,
                    title: 'App Name',
                    subtitle: 'Blood Pressure Monitor',
                  ),
                  const Divider(),
                  _buildSettingTile(
                    icon: Icons.numbers,
                    title: 'Version',
                    subtitle: '1.0.0',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing,
          ],
        ],
      ),
    );
  }

  Future<void> _toggleNotifications(bool enable) async {
    if (enable) {
      // Request permissions
      final granted = await _notificationService.requestPermissions();
      if (granted) {
        await _notificationService.scheduleDailyCheckInReminder();
        setState(() {
          _notificationsEnabled = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Daily reminder set for 7:00 PM',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.normal,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Permissions denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please enable notifications in system settings',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      // Disable notifications
      await _notificationService.cancelDailyCheckInReminder();
      setState(() {
        _notificationsEnabled = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_off, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Daily reminder disabled',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: AppTextStyles.heading3,
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyLarge,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      if (!mounted) return;
      
      // Capture BuildContext-dependent objects before async call
      // ignore: use_build_context_synchronously
      final messenger = ScaffoldMessenger.of(context);
      // ignore: use_build_context_synchronously
      final authController = Provider.of<AuthController>(context, listen: false);
      
      await authController.signOut();

      if (!mounted) return;
      
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Successfully signed out',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

