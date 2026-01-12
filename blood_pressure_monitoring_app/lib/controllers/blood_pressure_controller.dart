import 'package:flutter/foundation.dart';
import '../models/blood_pressure_reading.dart';
import '../repositories/blood_pressure_repository.dart';

/// Controller for blood pressure data
/// Follows SRP - Only manages BP data state
/// Uses Provider for state management
class BloodPressureController extends ChangeNotifier {
  final BloodPressureRepository _repository;

  BloodPressureReading? _currentReading;
  List<BloodPressureReading> _historicalReadings = [];
  bool _isLoading = false;
  String? _error;

  BloodPressureController(this._repository, {bool enableRealtime = true}) {
    _initialize(enableRealtime);
  }

  // Getters
  BloodPressureReading? get currentReading => _currentReading;
  List<BloodPressureReading> get historicalReadings => _historicalReadings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _currentReading != null;

  /// Initialize controller and load data
  Future<void> _initialize(bool enableRealtime) async {
    await loadCurrentReading();
    await loadHistoricalReadings();
    if (enableRealtime) {
      _startRealtimeUpdates();
    }
  }

  /// Load current blood pressure reading
  Future<void> loadCurrentReading() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentReading = await _repository.getCurrentReading();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load current reading: $e';
      notifyListeners();
    }
  }

  /// Load historical readings
  Future<void> loadHistoricalReadings() async {
    try {
      _error = null;

      _historicalReadings = await _repository.getReadings(
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load historical readings: $e';
      notifyListeners();
    }
  }

  /// Start listening to real-time updates
  void _startRealtimeUpdates() {
    _repository.watchReadings().listen(
      (reading) {
        _currentReading = reading;

        // Add to historical readings
        _historicalReadings.add(reading);

        // Keep only last 30 readings
        if (_historicalReadings.length > 30) {
          _historicalReadings.removeAt(0);
        }

        notifyListeners();
      },
      onError: (error) {
        _error = 'Real-time update error: $error';
        notifyListeners();
      },
    );
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([loadCurrentReading(), loadHistoricalReadings()]);
  }

  /// Get readings for a specific time range
  Future<List<BloodPressureReading>> getReadingsForRange({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      return await _repository.getReadings(
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      _error = 'Failed to load readings for range: $e';
      notifyListeners();
      return [];
    }
  }
}
