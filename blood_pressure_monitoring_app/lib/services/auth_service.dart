import 'package:firebase_auth/firebase_auth.dart';

/// Service for handling Firebase Authentication operations
/// Follows SRP: Only responsible for auth operations
/// Follows DIP: Depends on FirebaseAuth abstraction
class AuthService {
  final FirebaseAuth _auth;

  /// Constructor with optional FirebaseAuth instance for testing
  AuthService({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  /// Get the current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update display name. Please try again.');
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    if (currentUser == null) {
      throw Exception('No user is currently signed in.');
    }
    try {
      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly Exception
  Exception _handleAuthException(FirebaseAuthException e) {
    final message = switch (e.code) {
      'weak-password' => 'The password provided is too weak. Please use at least 6 characters.',
      'email-already-in-use' => 'An account already exists for this email.',
      'invalid-email' => 'The email address is not valid.',
      'operation-not-allowed' => 'Email/password accounts are not enabled.',
      'user-disabled' => 'This user account has been disabled.',
      'user-not-found' => 'No user found with this email.',
      'wrong-password' => 'Wrong password provided.',
      'invalid-credential' => 'The credentials provided are invalid.',
      'requires-recent-login' => 'This operation requires recent authentication. Please sign in again.',
      'too-many-requests' => 'Too many failed attempts. Please try again later.',
      _ => 'An error occurred: ${e.message ?? 'Unknown error'}',
    };
    return Exception(message);
  }
}
