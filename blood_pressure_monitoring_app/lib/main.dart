import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';
import 'views/main_navigation.dart';
import 'views/auth/login_screen.dart';
import 'views/questionnaire/questionnaire_screen.dart';
import 'controllers/blood_pressure_controller.dart';
import 'controllers/device_controller.dart';
import 'controllers/questionnaire_controller.dart';
import 'controllers/auth_controller.dart';
import 'repositories/blood_pressure_repository.dart';
import 'repositories/device_repository.dart';
import 'repositories/questionnaire_repository.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';

// Note: firebase_auth import needed for User type in AuthWrapper

// Global navigator key for handling notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Set preferred orientations and system UI
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize notification service (does not request permissions or schedule)
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Set up notification tap handler
  notificationService.onNotificationTap = (payload) {
    if (payload == 'questionnaire') {
      // Navigate to questionnaire when notification is tapped
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) =>
              const QuestionnaireScreen(templateId: 'orthostatic_assessment'),
        ),
      );
    }
  };

  // Note: Notifications will only be scheduled when user explicitly
  // enables them through the Settings screen toggle

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
    final authService = AuthService();

    return MultiProvider(
      providers: [
        // Auth Controller
        ChangeNotifierProvider(create: (_) => AuthController(authService)),
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
        home: const AuthWrapper(),
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

/// Wrapper widget that handles authentication state
/// Shows login screen if not authenticated, main navigation if authenticated
/// Follows SRP: Only responsible for routing based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Access AuthController to get the auth state stream
    final authController = context.read<AuthController>();

    // Use StreamBuilder with AuthController's stream (maintains abstraction)
    return StreamBuilder<User?>(
      stream: authController.authStateChanges,
      initialData: authController.user,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show login screen if not signed in
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // Show main navigation if signed in
        return const MainNavigation();
      },
    );
  }
}
