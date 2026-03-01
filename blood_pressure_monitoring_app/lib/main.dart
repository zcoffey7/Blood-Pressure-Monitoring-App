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
import 'repositories/blood_pressure_repository.dart';
import 'repositories/firebase_questionnaire_repository.dart';
import 'repositories/alert_repository.dart';
import 'repositories/ble_device_repository.dart';
import 'services/bluetooth_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    runApp(_ErrorApp(message: 'Failed to initialize Firebase: $e'));
    return;
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final notificationService = NotificationService();
  try {
    await notificationService.initialize();
  } catch (_) {
    // Non-critical: app can function without notifications
  }

  final authService = AuthService();

  runApp(BloodPressureMonitorApp(authService: authService));
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BloodPressureMonitorApp extends StatelessWidget {
  final AuthService authService;

  const BloodPressureMonitorApp({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
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
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            navigatorKey: navigatorKey,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onSurface =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardBg =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final cardBorder =
        isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final inputFill =
        isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final indicatorAlpha = isDark ? 0.2 : 0.12;

    final appBarFg = isDark ? AppColors.darkTextPrimary : Colors.white;
    final appBarBg = isDark ? AppColors.darkSurface : AppColors.primary;
    final outlinedFg = isDark ? AppColors.primary : AppColors.buttonSecondary;

    const baseTextTheme = TextTheme(
      displayLarge: AppTextStyles.heading1,
      displayMedium: AppTextStyles.heading2,
      displaySmall: AppTextStyles.heading3,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.button,
    );

    final textTheme = isDark
        ? baseTextTheme.apply(
            bodyColor: AppColors.darkTextPrimary,
            displayColor: AppColors.darkTextPrimary,
          )
        : baseTextTheme;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: surface,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: appBarFg,
        ),
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: cardBg,
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
          foregroundColor: outlinedFg,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: outlinedFg, width: 1.5),
        ),
      ),
      iconTheme: IconThemeData(size: 28, color: onSurface),
      dividerTheme: DividerThemeData(color: divider, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primary.withValues(alpha: indicatorAlpha),
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
          return const Scaffold(
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
/// Uses StatefulWidget so services/repos are created once per user session,
/// not on every rebuild.
class _AuthenticatedProviders extends StatefulWidget {
  final String userId;
  final Widget child;

  const _AuthenticatedProviders({
    required this.userId,
    required this.child,
  });

  @override
  State<_AuthenticatedProviders> createState() =>
      _AuthenticatedProvidersState();
}

class _AuthenticatedProvidersState extends State<_AuthenticatedProviders> {
  late final FirestoreService _firestoreService;
  late final MockBloodPressureRepository _bpRepo;
  late final FirebaseQuestionnaireRepository _questionnaireRepo;
  late final FirebaseAlertRepository _alertRepo;
  late final BluetoothService _bleService;
  late final BleDeviceRepository _deviceRepo;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _firestoreService.initializeUserDocument();

    _bpRepo = MockBloodPressureRepository();
    _questionnaireRepo = FirebaseQuestionnaireRepository(_firestoreService);
    _alertRepo = FirebaseAlertRepository(_firestoreService);
    _bleService = BluetoothService();
    _deviceRepo = BleDeviceRepository(_bleService);
  }

  @override
  void dispose() {
    _deviceRepo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      key: ValueKey(widget.userId),
      providers: [
        ChangeNotifierProvider(
            create: (_) => BloodPressureController(_bpRepo)),
        ChangeNotifierProvider(
            create: (_) => DeviceController(_deviceRepo)),
        ChangeNotifierProvider(
            create: (_) => QuestionnaireController(_questionnaireRepo,
                userId: widget.userId)),
        ChangeNotifierProvider(
            create: (_) => AlertController(_alertRepo)),
      ],
      child: _NotificationTapHandler(child: widget.child),
    );
  }
}

/// Sets up the notification tap handler with access to user-scoped providers.
/// Must be a child of MultiProvider so it can read QuestionnaireController.
class _NotificationTapHandler extends StatefulWidget {
  final Widget child;
  const _NotificationTapHandler({required this.child});

  @override
  State<_NotificationTapHandler> createState() =>
      _NotificationTapHandlerState();
}

class _NotificationTapHandlerState extends State<_NotificationTapHandler> {
  @override
  void initState() {
    super.initState();
    final notificationService = NotificationService();
    notificationService.onNotificationTap = (payload) {
      if (payload == 'symptom_tracker' && mounted) {
        final controller = context.read<QuestionnaireController>();
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: const QuestionnaireScreen(templateId: 'symptom_tracker'),
            ),
          ),
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
