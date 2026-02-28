import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../services/notification_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';

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
    try {
      final hasPermissions = await _notificationService.areNotificationsEnabled();
      final isScheduled = await _notificationService.isDailyReminderScheduled();
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = hasPermissions && isScheduled;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings',
                  style: AppTextStyles.heading1
                      .copyWith(color: colorScheme.onSurface)),
              const SizedBox(height: 24),

              // ── Appearance ────────────────────────────────
              _buildSectionCard(
                context,
                title: 'Appearance',
                icon: Icons.palette_rounded,
                children: [
                  Consumer<ThemeController>(
                    builder: (context, themeCtrl, _) {
                      return _buildSettingTile(
                        context,
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark Mode',
                        subtitle: themeCtrl.isDarkMode
                            ? 'Dark theme active'
                            : 'Light theme active',
                        trailing: Switch.adaptive(
                          value: themeCtrl.isDarkMode,
                          onChanged: (_) => themeCtrl.toggleTheme(),
                          activeTrackColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Account ───────────────────────────────────
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  return _buildSectionCard(
                    context,
                    title: 'Account',
                    icon: Icons.person_rounded,
                    children: [
                      _buildSettingTile(context,
                          icon: Icons.email,
                          title: 'Email',
                          subtitle:
                              authController.userEmail ?? 'Not available'),
                      Divider(color: AppColors.divider(context)),
                      _buildSettingTile(context,
                          icon: Icons.badge,
                          title: 'Display Name',
                          subtitle:
                              authController.userDisplayName ?? 'Not set'),
                      Divider(color: AppColors.divider(context)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton.icon(
                          onPressed: () => _handleSignOut(context),
                          icon: const Icon(Icons.logout, size: 24),
                          label: const Text('Sign Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonDanger,
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── Notifications ─────────────────────────────
              _buildSectionCard(
                context,
                title: 'Notifications',
                icon: Icons.notifications_rounded,
                children: [
                  if (_isLoading)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator()))
                  else ...[
                    _buildSettingTile(context,
                        icon: Icons.alarm,
                        title: 'Daily Reminder',
                        subtitle: '7:00 PM daily check-in',
                        trailing: Switch.adaptive(
                          value: _notificationsEnabled,
                          onChanged: _toggleNotifications,
                          activeTrackColor: AppColors.primary,
                        )),
                    Divider(color: AppColors.divider(context)),
                    _buildSettingTile(
                      context,
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
                            : AppColors.textSecondary(context),
                        size: 28,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // ── About ─────────────────────────────────────
              _buildSectionCard(
                context,
                title: 'About',
                icon: Icons.info_rounded,
                children: [
                  _buildSettingTile(context,
                      icon: Icons.medical_services,
                      title: 'App Name',
                      subtitle: 'Blood Pressure Monitor'),
                  Divider(color: AppColors.divider(context)),
                  _buildSettingTile(context,
                      icon: Icons.numbers,
                      title: 'Version',
                      subtitle: '1.0.0'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              Text(title,
                  style: AppTextStyles.heading3.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary(context), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 16), trailing],
        ],
      ),
    );
  }

  Future<void> _toggleNotifications(bool enable) async {
    try {
      if (enable) {
        final granted = await _notificationService.requestPermissions();
        if (granted) {
          await _notificationService.scheduleDailyCheckInReminder();
          if (!mounted) return;
          setState(() => _notificationsEnabled = true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Daily reminder set for 7:00 PM'),
            backgroundColor: AppColors.normal,
            behavior: SnackBarBehavior.floating,
          ));
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                const Text('Please enable notifications in system settings'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        await _notificationService.cancelDailyCheckInReminder();
        if (!mounted) return;
        setState(() => _notificationsEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Daily reminder disabled'),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to update notification settings'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final authController =
        Provider.of<AuthController>(context, listen: false);

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out', style: AppTextStyles.heading3),
        content:
            Text('Are you sure you want to sign out?', style: AppTextStyles.bodyLarge),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: AppTextStyles.bodyLarge)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonDanger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await authController.signOut();
      messenger.showSnackBar(SnackBar(
        content: const Text('Successfully signed out'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
