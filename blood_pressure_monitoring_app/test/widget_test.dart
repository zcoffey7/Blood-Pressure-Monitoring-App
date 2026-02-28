import 'package:flutter_test/flutter_test.dart';

import 'package:blood_pressure_monitoring_app/main.dart';
import 'package:blood_pressure_monitoring_app/repositories/blood_pressure_repository.dart';
import 'package:blood_pressure_monitoring_app/repositories/device_repository.dart';
import 'package:blood_pressure_monitoring_app/repositories/questionnaire_repository.dart';
import 'package:blood_pressure_monitoring_app/services/auth_service.dart';

BloodPressureMonitorApp buildTestApp() {
  return BloodPressureMonitorApp(
    bpRepository: MockBloodPressureRepository(),
    deviceRepository: MockDeviceRepository(),
    questionnaireRepository: MockQuestionnaireRepository(),
    authService: AuthService(),
  );
}

void main() {
  testWidgets('App loads and displays home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Live Monitoring'), findsOneWidget);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Live Monitoring'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsNWidgets(2));

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();

    expect(find.text('Alerts'), findsNWidgets(2));

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsNWidgets(2));
  });
}
