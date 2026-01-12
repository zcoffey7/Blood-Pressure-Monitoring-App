// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:blood_pressure_monitoring_app/main.dart';

void main() {
  testWidgets('App loads and displays home screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BloodPressureMonitorApp());

    // Verify that the home screen loads with "Live Monitoring" text
    expect(find.text('Live Monitoring'), findsOneWidget);

    // Verify that bottom navigation is present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches screens', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BloodPressureMonitorApp());

    // Verify we start on Home screen
    expect(find.text('Live Monitoring'), findsOneWidget);

    // Tap on History tab
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // Verify History screen is shown
    expect(find.text('History'), findsNWidgets(2)); // One in tab, one in header

    // Tap on Alerts tab
    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();

    // Verify Alerts screen is shown
    expect(find.text('Alerts'), findsNWidgets(2)); // One in tab, one in header

    // Tap on Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify Settings screen is shown
    expect(
      find.text('Settings'),
      findsNWidgets(2),
    ); // One in tab, one in header
  });
}
