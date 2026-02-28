import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blood_pressure_reading.dart';
import '../services/firestore_service.dart';
import 'blood_pressure_repository.dart';

/// Firebase Firestore implementation of BloodPressureRepository
/// Stores readings in: users/{userId}/tests/{testId}
/// Follows OCP - Extends BloodPressureRepository without modifying it
/// Follows SRP - Only responsible for Firestore blood pressure data operations
class FirebaseBloodPressureRepository implements BloodPressureRepository {
  final FirestoreService _firestoreService;

  FirebaseBloodPressureRepository(this._firestoreService);

  /// Reference to the user's tests collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestoreService.testsCollection;

  @override
  Future<BloodPressureReading?> getCurrentReading() async {
    try {
      final snapshot = await _collection
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return _fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get current reading: $e');
    }
  }

  @override
  Future<List<BloodPressureReading>> getReadings({
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _collection.orderBy('timestamp', descending: false);

      if (startTime != null) {
        query = query.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startTime),
        );
      }

      if (endTime != null) {
        query = query.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endTime),
        );
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs.map(_fromFirestore).toList();
    } catch (e) {
      throw Exception('Failed to get readings: $e');
    }
  }

  @override
  Future<void> addReading(BloodPressureReading reading) async {
    try {
      await _collection.add(_toFirestore(reading));
    } catch (e) {
      throw Exception('Failed to add reading: $e');
    }
  }

  @override
  Stream<BloodPressureReading> watchReadings() {
    return _collection
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .where((snapshot) => snapshot.docs.isNotEmpty)
        .map((snapshot) => _fromFirestore(snapshot.docs.first));
  }

  /// Convert a BloodPressureReading to a Firestore-compatible map
  /// Uses Firestore Timestamp for proper date ordering and querying
  Map<String, dynamic> _toFirestore(BloodPressureReading reading) {
    return {
      'systolic': reading.systolic,
      'diastolic': reading.diastolic,
      'heartRate': reading.heartRate,
      'timestamp': Timestamp.fromDate(reading.timestamp),
      'status': reading.status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert a Firestore document to a BloodPressureReading
  BloodPressureReading _fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return BloodPressureReading(
      systolic: data['systolic'] as int,
      diastolic: data['diastolic'] as int,
      heartRate: data['heartRate'] as int,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: BloodPressureStatus.values.byName(data['status'] as String),
    );
  }
}
