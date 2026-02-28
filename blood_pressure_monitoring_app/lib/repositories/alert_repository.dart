import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert.dart';
import '../services/firestore_service.dart';

/// Abstract repository interface for alert data
/// Follows OCP - Open for extension (can implement different backends)
/// Follows DIP - Depends on abstraction, not concrete implementation
abstract class AlertRepository {
  /// Get all alerts for the current user
  Future<List<HealthAlert>> getAlerts({bool includeRead = true});

  /// Get unread alert count
  Future<int> getUnreadCount();

  /// Add a new alert
  Future<void> addAlert(HealthAlert alert);

  /// Mark an alert as read
  Future<void> markAsRead(String alertId);

  /// Mark all alerts as read
  Future<void> markAllAsRead();

  /// Dismiss an alert
  Future<void> dismissAlert(String alertId);

  /// Delete an alert
  Future<void> deleteAlert(String alertId);

  /// Stream of alerts (for real-time updates)
  Stream<List<HealthAlert>> watchAlerts();
}

/// Firebase Firestore implementation of AlertRepository
/// Stores alerts in: users/{userId}/alerts/{alertId}
/// Follows OCP - Extends AlertRepository without modifying it
/// Follows SRP - Only responsible for Firestore alert data operations
class FirebaseAlertRepository implements AlertRepository {
  final FirestoreService _firestoreService;

  FirebaseAlertRepository(this._firestoreService);

  /// Reference to the user's alerts collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestoreService.alertsCollection;

  @override
  Future<List<HealthAlert>> getAlerts({bool includeRead = true}) async {
    try {
      Query<Map<String, dynamic>> query =
          _collection.orderBy('createdAt', descending: true);

      if (!includeRead) {
        query = query.where('isRead', isEqualTo: false);
      }

      // Don't show dismissed alerts
      query = query.where('isDismissed', isEqualTo: false);

      final snapshot = await query.get();
      return snapshot.docs.map(_fromFirestore).toList();
    } catch (e) {
      throw Exception('Failed to get alerts: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final snapshot = await _collection
          .where('isRead', isEqualTo: false)
          .where('isDismissed', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  @override
  Future<void> addAlert(HealthAlert alert) async {
    try {
      await _collection.doc(alert.id).set(_toFirestore(alert));
    } catch (e) {
      throw Exception('Failed to add alert: $e');
    }
  }

  @override
  Future<void> markAsRead(String alertId) async {
    try {
      await _collection.doc(alertId).update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark alert as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final snapshot = await _collection
          .where('isRead', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all alerts as read: $e');
    }
  }

  @override
  Future<void> dismissAlert(String alertId) async {
    try {
      await _collection.doc(alertId).update({
        'isDismissed': true,
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to dismiss alert: $e');
    }
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    try {
      await _collection.doc(alertId).delete();
    } catch (e) {
      throw Exception('Failed to delete alert: $e');
    }
  }

  @override
  Stream<List<HealthAlert>> watchAlerts() {
    return _collection
        .where('isDismissed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromFirestore).toList());
  }

  /// Convert a HealthAlert to a Firestore-compatible map
  Map<String, dynamic> _toFirestore(HealthAlert alert) {
    return {
      'id': alert.id,
      'title': alert.title,
      'message': alert.message,
      'type': alert.type.name,
      'severity': alert.severity.name,
      'createdAt': Timestamp.fromDate(alert.createdAt),
      'isRead': alert.isRead,
      'isDismissed': alert.isDismissed,
      if (alert.metadata != null) 'metadata': alert.metadata,
    };
  }

  /// Convert a Firestore document to a HealthAlert
  HealthAlert _fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return HealthAlert(
      id: data['id'] as String,
      title: data['title'] as String,
      message: data['message'] as String,
      type: AlertType.values.byName(data['type'] as String),
      severity: AlertSeverity.values.byName(data['severity'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool? ?? false,
      isDismissed: data['isDismissed'] as bool? ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}
