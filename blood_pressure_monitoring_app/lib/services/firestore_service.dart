import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized Firestore service for accessing user-scoped collections
/// Follows SRP - Only responsible for providing Firestore collection references
/// Follows DIP - Other classes depend on this abstraction for Firestore access
///
/// Firestore structure:
///   users/{userId}/
///     ├── tests/{testId}      - Blood pressure readings
///     ├── surveys/{surveyId}  - Questionnaire responses
///     └── alerts/{alertId}    - Health alerts
class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get the current authenticated user's UID
  /// Throws if no user is authenticated
  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user. Please sign in first.');
    }
    return user.uid;
  }

  /// Check if a user is currently authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get reference to the current user's document
  DocumentReference get userDocument =>
      _firestore.collection('users').doc(currentUserId);

  /// Get reference to the current user's tests collection (blood pressure readings)
  CollectionReference<Map<String, dynamic>> get testsCollection =>
      userDocument.collection('tests');

  /// Get reference to the current user's surveys collection (questionnaire responses)
  CollectionReference<Map<String, dynamic>> get surveysCollection =>
      userDocument.collection('surveys');

  /// Get reference to the current user's alerts collection
  CollectionReference<Map<String, dynamic>> get alertsCollection =>
      userDocument.collection('alerts');

  /// Initialize user document in Firestore (called on first sign-up or sign-in)
  /// Creates the user document if it doesn't exist
  Future<void> initializeUserDocument({
    String? email,
    String? displayName,
  }) async {
    final userDoc = userDocument;
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'email': email ?? _auth.currentUser?.email,
        'displayName': displayName ?? _auth.currentUser?.displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
