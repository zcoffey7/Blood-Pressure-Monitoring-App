import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/alert.dart';
import '../repositories/alert_repository.dart';

/// Controller for managing health alerts
/// Follows SRP - Only manages alert state and operations
/// Uses Provider for state management
class AlertController extends ChangeNotifier {
  final AlertRepository _repository;

  List<HealthAlert> _alerts = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<HealthAlert>>? _alertsSubscription;
  final Uuid _uuid = const Uuid();

  AlertController(this._repository) {
    _initialize();
  }

  // Getters
  List<HealthAlert> get alerts => _alerts;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAlerts => _alerts.isNotEmpty;
  bool get hasUnread => _unreadCount > 0;

  /// Initialize controller - start listening to real-time alerts
  void _initialize() {
    _startWatchingAlerts();
    loadAlerts();
  }

  /// Load all alerts from Firestore
  Future<void> loadAlerts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _alerts = await _repository.getAlerts();
      _unreadCount = await _repository.getUnreadCount();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load alerts: $e';
      notifyListeners();
    }
  }

  /// Start listening to real-time alert updates
  void _startWatchingAlerts() {
    _alertsSubscription = _repository.watchAlerts().listen(
      (alerts) {
        _alerts = alerts;
        _unreadCount = alerts.where((a) => !a.isRead).length;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Alert stream error: $error';
        notifyListeners();
      },
    );
  }

  /// Create and add a new alert
  Future<void> createAlert({
    required String title,
    required String message,
    required AlertType type,
    AlertSeverity severity = AlertSeverity.info,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final alert = HealthAlert(
        id: _uuid.v4(),
        title: title,
        message: message,
        type: type,
        severity: severity,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await _repository.addAlert(alert);
      // Real-time listener will update the list
    } catch (e) {
      _error = 'Failed to create alert: $e';
      notifyListeners();
    }
  }

  /// Mark a specific alert as read
  Future<void> markAsRead(String alertId) async {
    try {
      await _repository.markAsRead(alertId);
      // Real-time listener will update the list
    } catch (e) {
      _error = 'Failed to mark alert as read: $e';
      notifyListeners();
    }
  }

  /// Mark all alerts as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
    } catch (e) {
      _error = 'Failed to mark all as read: $e';
      notifyListeners();
    }
  }

  /// Dismiss an alert (hide from list)
  Future<void> dismissAlert(String alertId) async {
    try {
      await _repository.dismissAlert(alertId);
    } catch (e) {
      _error = 'Failed to dismiss alert: $e';
      notifyListeners();
    }
  }

  /// Delete an alert permanently
  Future<void> deleteAlert(String alertId) async {
    try {
      await _repository.deleteAlert(alertId);
    } catch (e) {
      _error = 'Failed to delete alert: $e';
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh alerts
  Future<void> refresh() async {
    await loadAlerts();
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    super.dispose();
  }
}
