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
import 'controllers/alert_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'repositories/firebase_blood_pressure_repository.dart';
import 'repositories/firebase_questionnaire_repository.dart';
import 'repositories/alert_repository.dart';
import 'repositories/device_repository.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final notificationService = NotificationService();
  await notificationService.initialize();

  notificationService.onNotificationTap = (payload) {
    if (payload == 'symptom_tracker') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) =>
              const QuestionnaireScreen(templateId: 'symptom_tracker'),
        ),
      );
    }
  };

  runApp(const BloodPressureMonitorApp());
}

class BloodPressureMonitorApp extends StatelessWidget {
  const BloodPressureMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => AuthController(authService)),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'BP Monitor',
            debugShowCheckedModeBanner: false,
            themeMode: themeController.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            navigatorKey: navigatorKey,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.heading1,
        displayMedium: AppTextStyles.heading2,
        displaySmall: AppTextStyles.heading3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.buttonSecondary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppColors.buttonSecondary, width: 1.5),
        ),
      ),
      iconTheme:
          const IconThemeData(size: 28, color: AppColors.lightTextPrimary),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge:
            AppTextStyles.heading1.copyWith(color: AppColors.darkTextPrimary),
        displayMedium:
            AppTextStyles.heading2.copyWith(color: AppColors.darkTextPrimary),
        displaySmall:
            AppTextStyles.heading3.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
        bodySmall:
            AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextSecondary),
        labelLarge: AppTextStyles.button,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      iconTheme:
          const IconThemeData(size: 28, color: AppColors.darkTextPrimary),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();

    return StreamBuilder<User?>(
      stream: authController.authStateChanges,
      initialData: authController.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        final user = snapshot.data!;
        return _AuthenticatedProviders(
          userId: user.uid,
          child: const MainNavigation(),
        );
      },
    );
  }
}

/// Provides user-scoped data providers that depend on authentication.
/// Keyed by userId so providers recreate when user changes.
class _AuthenticatedProviders extends StatelessWidget {
  final String userId;
  final Widget child;

  const _AuthenticatedProviders({
    required this.userId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    firestoreService.initializeUserDocument();

    final bpRepo = FirebaseBloodPressureRepository(firestoreService);
    final questionnaireRepo = FirebaseQuestionnaireRepository(firestoreService);
    final alertRepo = FirebaseAlertRepository(firestoreService);
    final deviceRepo = MockDeviceRepository();

    return MultiProvider(
      key: ValueKey(userId),
      providers: [
        ChangeNotifierProvider(
            create: (_) => BloodPressureController(bpRepo)),
        ChangeNotifierProvider(
            create: (_) => DeviceController(deviceRepo)),
        ChangeNotifierProvider(
            create: (_) =>
                QuestionnaireController(questionnaireRepo, userId: userId)),
        ChangeNotifierProvider(
            create: (_) => AlertController(alertRepo)),
      ],
      child: child,
    );
  }
}
