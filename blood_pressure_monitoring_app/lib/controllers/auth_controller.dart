import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Controller for managing authentication state
/// Follows SRP: Only responsible for auth state and operations
class AuthController extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  AuthController(this._authService) {
    // Initialize with current user
    _user = _authService.currentUser;

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? _user;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    // Cancel stream subscription to prevent memory leaks
    _authSubscription?.cancel();
    super.dispose();
  }

  // Getters
  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userEmail => _user?.email;
  String? get userDisplayName => _user?.displayName;

  /// Auth state stream for direct listening
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Sign up with email and password
  /// Returns true on success, false on failure
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await _authService.updateDisplayName(displayName);
      }

      // No need to manually update _user - stream listener handles it
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with email and password
  /// Returns true on success, false on failure
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // No need to manually update _user - stream listener handles it
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update display name
  Future<bool> updateDisplayName(String displayName) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateDisplayName(displayName);
      _user = _authService.currentUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
