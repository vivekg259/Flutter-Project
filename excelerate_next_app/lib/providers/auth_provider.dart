/// Auth provider — initializing / authenticated / unauthenticated.
///
/// signUp() stages the user in Firebase Auth (sends verification email),
/// then signs out. The caller must navigate to the verification screen.
/// User can only sign in after email is verified.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';

enum AuthStatus { initializing, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  final AuthService _authService;

  AppUser? _user;
  AuthStatus _status = AuthStatus.initializing;
  String? _errorMessage;
  bool _isLoading = false;

  /// Set to true during signIn/signUp so the authStateChanges listener
  /// doesn't race with the manual state transition.
  bool _busy = false;

  AppUser? get currentUser => _user;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> _onAuthChanged(User? user) async {
    // Skip while signIn/signUp is manually managing state
    if (_busy) return;

    if (user == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // ---- CRITICAL: reload to get REAL server state, not cached ----
    // Firebase caches auth tokens on-device for fast session restore.
    // Cached emailVerified can be stale (showing true when it's false).
    // `user.reload()` forces a server round-trip for the real value.
    bool verified;
    try {
      await user.reload();
      verified = _authService.auth.currentUser?.emailVerified ?? false;
    } catch (_) {
      // Network error — fall back to cached value
      verified = user.emailVerified;
    }

    // ---- Guard: block unverified users ----
    if (!verified) {
      await _authService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      _user = await _authService.loadCurrentAppUser();
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (_) {
      await _authService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // =========================================================================
  // SIGN IN
  // =========================================================================

  Future<void> signIn({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? nationality,
  }) async {
    _busy = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        nationality: nationality,
      );
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = friendlyError(e);
      rethrow;
    } finally {
      _busy = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // SIGN UP
  // =========================================================================

  Future<String> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String nationality,
    required String password,
  }) async {
    _busy = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _authService.signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        nationality: nationality,
        password: password,
      );

      // New accounts always land in the unverified staging state. The first
      // verified sign-in creates the Firestore document (role = learner).
      // Admin access is granted manually in the Firebase Console.
      _user = null;
      _status = AuthStatus.unauthenticated;
      return result;
    } catch (e) {
      _errorMessage = friendlyError(e);
      rethrow;
    } finally {
      _busy = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // RESEND
  // =========================================================================

  Future<void> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    // Guard the auth-state listener during the resend sign-in/sign-out so the
    // unverified-user handler does not race the flow (see _onAuthChanged).
    _busy = true;
    try {
      await _authService.resendVerificationEmail(
        email: email,
        password: password,
      );
    } finally {
      _busy = false;
    }
  }

  // =========================================================================
  // MISC
  // =========================================================================

  Future<void> refreshUser() async {
    try {
      _user = await _authService.loadCurrentAppUser();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> resetPassword(String email) async {
    await _authService.sendPasswordReset(email);
  }

  Future<void> signOut() async {
    _busy = true;
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    _busy = false;
    notifyListeners();
  }
}
