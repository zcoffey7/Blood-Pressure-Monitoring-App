import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';
import 'views/main_navigation.dart';
import 'views/questionnaire/questionnaire_screen.dart';
import 'controllers/blood_pressure_controller.dart';
import 'controllers/device_controller.dart';
import 'controllers/questionnaire_controller.dart';
import 'repositories/blood_pressure_repository.dart';
import 'repositories/device_repository.dart';
import 'repositories/questionnaire_repository.dart';
import 'services/notification_service.dart';

// Global navigator key for handling notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Set preferred orientations and system UI
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Set up notification tap handler
  notificationService.onNotificationTap = (payload) {
    if (payload == 'questionnaire') {
      // Navigate to questionnaire when notification is tapped
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const QuestionnaireScreen(
            templateId: 'orthostatic_assessment',
          ),
        ),
      );
    }
  };

  // Request permissions and schedule daily reminder
  final permissionGranted = await notificationService.requestPermissions();
  if (permissionGranted) {
    await notificationService.scheduleDailyCheckInReminder();
  }

  runApp(const BloodPressureMonitorApp());
}

/// Root application widget
/// Configures app-wide theme optimized for elderly users
class BloodPressureMonitorApp extends StatelessWidget {
  const BloodPressureMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repositories (can be easily swapped with Firebase/API)
    final bpRepository = MockBloodPressureRepository();
    final deviceRepository = MockDeviceRepository();
    final questionnaireRepository = MockQuestionnaireRepository();

    return MultiProvider(
      providers: [
        // Blood Pressure Controller
        ChangeNotifierProvider(
          create: (_) => BloodPressureController(bpRepository),
        ),
        // Device Controller
        ChangeNotifierProvider(
          create: (_) => DeviceController(deviceRepository),
        ),
        // Questionnaire Controller
        ChangeNotifierProvider(
          create: (_) => QuestionnaireController(questionnaireRepository),
        ),
      ],
      child: MaterialApp(
        title: 'BP Monitor',
        debugShowCheckedModeBanner: false,
        theme: _buildAppTheme(),
        navigatorKey: navigatorKey,
        home: const MainNavigation(),
      ),
    );
  }

  /// Build custom theme optimized for elderly users
  /// High contrast colors and large text for accessibility
  ThemeData _buildAppTheme() {
    return ThemeData(
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: AppColors.background,
      ),

      // Scaffold background
      scaffoldBackgroundColor: AppColors.background,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Text theme - Large fonts for elderly users
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.heading1,
        displayMedium: AppTextStyles.heading2,
        displaySmall: AppTextStyles.heading3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.buttonSecondary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.buttonSecondary, width: 2),
        ),
      ),

      // Icon theme - Larger icons for visibility
      iconTheme: const IconThemeData(size: 28, color: AppColors.textPrimary),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),

      // Use Material 3
      useMaterial3: true,
    );
  }
}
