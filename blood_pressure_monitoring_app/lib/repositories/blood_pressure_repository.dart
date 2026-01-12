import '../models/blood_pressure_reading.dart';
import '../utils/blood_pressure_status.dart';

/// Repository for blood pressure data
/// Follows Repository Pattern - Easy to swap implementation with Firebase/API
/// Follows OCP - Can extend with new data sources without modifying existing code
abstract class BloodPressureRepository {
  /// Get the current blood pressure reading
  Future<BloodPressureReading?> getCurrentReading();

  /// Get historical readings for a time range
  Future<List<BloodPressureReading>> getReadings({
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
  });

  /// Add a new reading
  Future<void> addReading(BloodPressureReading reading);

  /// Stream of real-time readings (for live monitoring)
  Stream<BloodPressureReading> watchReadings();
}

/// Mock implementation for development
/// TODO: Replace with Firebase/API implementation
class MockBloodPressureRepository implements BloodPressureRepository {
  // Simulated current reading
  BloodPressureReading _currentReading = BloodPressureReading(
    systolic: 120,
    diastolic: 74,
    heartRate: 73,
    timestamp: DateTime.now(),
    status: BloodPressureStatusUtil.getStatus(120, 74),
  );

  @override
  Future<BloodPressureReading?> getCurrentReading() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentReading;
  }

  @override
  Future<List<BloodPressureReading>> getReadings({
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Generate mock historical data
    final now = DateTime.now();
    final readings = <BloodPressureReading>[];

    // Generate readings for the last 30 minutes (every 2 minutes)
    for (int i = 0; i < 15; i++) {
      final timestamp = now.subtract(Duration(minutes: i * 2));
      final systolic = 110 + (i % 5) * 5; // Varies between 110-130
      final diastolic = 70 + (i % 4) * 3; // Varies between 70-79
      final heartRate = 70 + (i % 6) * 2; // Varies between 70-80

      readings.add(
        BloodPressureReading(
          systolic: systolic,
          diastolic: diastolic,
          heartRate: heartRate,
          timestamp: timestamp,
          status: BloodPressureStatusUtil.getStatus(systolic, diastolic),
        ),
      );
    }

    return readings.reversed.toList(); // Chronological order
  }

  @override
  Future<void> addReading(BloodPressureReading reading) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    _currentReading = reading;
  }

  @override
  Stream<BloodPressureReading> watchReadings() async* {
    // Simulate real-time updates every 5 seconds
    while (true) {
      await Future.delayed(const Duration(seconds: 5));

      // Generate slightly varied reading
      final systolic = 110 + (DateTime.now().second % 10) * 2;
      final diastolic = 70 + (DateTime.now().second % 5) * 2;
      final heartRate = 70 + (DateTime.now().second % 8);

      _currentReading = BloodPressureReading(
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        timestamp: DateTime.now(),
        status: BloodPressureStatusUtil.getStatus(systolic, diastolic),
      );

      yield _currentReading;
    }
  }
}
