import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:blood_pressure_monitoring_app/views/main_navigation.dart';
import 'package:blood_pressure_monitoring_app/controllers/blood_pressure_controller.dart';
import 'package:blood_pressure_monitoring_app/controllers/device_controller.dart';
import 'package:blood_pressure_monitoring_app/controllers/questionnaire_controller.dart';
import 'package:blood_pressure_monitoring_app/controllers/theme_controller.dart';
import 'package:blood_pressure_monitoring_app/controllers/auth_controller.dart';
import 'package:blood_pressure_monitoring_app/repositories/device_repository.dart';
import 'package:blood_pressure_monitoring_app/repositories/blood_pressure_repository.dart';
import 'package:blood_pressure_monitoring_app/repositories/questionnaire_repository.dart';
import 'package:blood_pressure_monitoring_app/services/auth_service.dart';

/// Builds MainNavigation wrapped with all required providers,
/// bypassing Firebase auth by providing mocked Firebase Core.
Widget buildTestNavigation() {
  final authService = AuthService();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(create: (_) => AuthController(authService)),
      ChangeNotifierProvider(
          create: (_) => BloodPressureController(
              MockBloodPressureRepository(),
              enableRealtime: false)),
      ChangeNotifierProvider(
          create: (_) =>
              DeviceController(MockDeviceRepository(), enableMonitoring: false)),
      ChangeNotifierProvider(
          create: (_) =>
              QuestionnaireController(MockQuestionnaireRepository())),
    ],
    child: const MaterialApp(home: MainNavigation()),
  );
}

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  testWidgets('MainNavigation loads and displays home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestNavigation());
    await tester.pump();

    expect(find.text('Live Monitoring'), findsOneWidget);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Check-Ins'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Drain short-lived timers from mock repository network delay simulation
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Bottom navigation switches screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestNavigation());
    await tester.pump();

    expect(find.text('Live Monitoring'), findsOneWidget);

    await tester.tap(find.text('Check-Ins'));
    await tester.pump();

    // "Check-Ins" appears in both nav bar and screen AppBar
    expect(find.text('Check-Ins'), findsNWidgets(2));

    await tester.tap(find.text('Alerts'));
    await tester.pump();

    // Alerts appears in both nav bar and screen header
    expect(find.text('Alerts'), findsNWidgets(2));

    await tester.tap(find.text('Settings'));
    await tester.pump();

    // Settings appears in both nav bar and screen header
    expect(find.text('Settings'), findsNWidgets(2));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
