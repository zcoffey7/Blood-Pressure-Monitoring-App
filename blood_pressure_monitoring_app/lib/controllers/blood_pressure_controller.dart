import 'dart:async';
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
  bool _isPaused = false;
  bool _isDisposed = false;
  StreamSubscription<BloodPressureReading>? _realtimeSubscription;

  BloodPressureController(this._repository, {bool enableRealtime = true}) {
    _initialize(enableRealtime);
  }

  // Getters
  BloodPressureReading? get currentReading => _currentReading;
  List<BloodPressureReading> get historicalReadings =>
      List.unmodifiable(_historicalReadings);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _currentReading != null;
  bool get isPaused => _isPaused;

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
      _isLoading = true;
      _error = null;
      notifyListeners();

      _historicalReadings = await _repository.getReadings(
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load historical readings: $e';
      notifyListeners();
    }
  }

  /// Start listening to real-time updates
  void _startRealtimeUpdates() {
    _realtimeSubscription = _repository.watchReadings().listen(
      (reading) {
        // Only update if not paused
        if (!_isPaused) {
          _currentReading = reading;

          // Add to historical readings
          _historicalReadings.add(reading);

          // Keep only last 30 readings
          if (_historicalReadings.length > 30) {
            _historicalReadings.removeAt(0);
          }

          notifyListeners();
        }
      },
      onError: (error) {
        _error = 'Real-time update error: $error';
        notifyListeners();
      },
    );
  }

  /// Pause real-time data updates
  void pauseMonitoring() {
    _isPaused = true;
    notifyListeners();
  }

  /// Resume real-time data updates
  void resumeMonitoring() {
    _isPaused = false;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _realtimeSubscription?.cancel();
    super.dispose();
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
