/// Authentication service — Firebase Auth + Firestore.
///
/// ## Business Logic
/// 1. **Signup (Staging)** — Creates Firebase Auth user ONLY. Sends verification
///    email. Does NOT create Firestore doc. Signs user out.
/// 2. **Email Verify** — User clicks link. Firebase marks emailVerified=true.
/// 3. **First Verified Sign-In** — signIn checks emailVerified. If Firestore doc
///    is missing, creates it now. Sets role=learner.
/// 4. **Conflict** — Firebase throws `email-already-in-use` if email exists in
///    Auth. UI shows 409-style message.
/// 5. **Re-creation** — If Firestore doc was deleted but Auth user still exists,
///    signIn recreates the doc on next verified login.
/// 6. **Forgot Password** — Firebase sends reset email (only if user exists).
///
/// Firebase equivalents for the spec:
/// | Spec              | Firebase                                      |
/// |-------------------|-----------------------------------------------|
/// | Staging table     | Firebase Auth (user exists, no Firestore doc)  |
/// | Verification token| Firebase `sendEmailVerification()` signed link |
/// | Main Users DB     | Firestore `users/{uid}`                       |
/// | 409 Conflict      | `email-already-in-use` FirebaseAuthException   |
/// | bcrypt/argon2     | Firebase handles password hashing natively     |
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../utils/constants.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Exposed for the provider so it can read `currentUser` after `reload()`.
  FirebaseAuth get auth => _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // =========================================================================
  // SIGN UP — Staging. Creates Auth user, verif email, NO Firestore doc.
  // =========================================================================

  Future<String> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String nationality,
    required String password,
  }) async {
    // Throws 'email-already-in-use' if conflict → 409
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Every account starts as an unverified learner. No Firestore document is
    // created here (staging) — it is created on first verified sign-in.
    // Admin access is granted manually in the Firebase Console afterwards.
    await cred.user!.sendEmailVerification();

    // Sign out — user is in staging (Auth = exists, Firestore = empty)
    await _auth.signOut();

    // Return email for the verification screen
    return email.trim();
  }

  // =========================================================================
  // SIGN IN — Block unverified. Create Firestore doc on first verified login.
  // =========================================================================

  Future<AppUser> signIn({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? nationality,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // ---- Block unverified users (all accounts verify email before first login) ----
    if (!cred.user!.emailVerified) {
      await _auth.signOut();
      throw Exception('Email not verified. Please check your inbox.');
    }

    final uid = cred.user!.uid;
    final doc = await _firestore
        .collection(AppCollections.users)
        .doc(uid)
        .get();

    // ---- Existing user (returning) ----
    if (doc.exists) {
      return AppUser.fromJson(doc.data()!, uid: uid);
    }

    // ---- First verified login / Re-created account ----
    // Create Firestore doc from signup metadata.
    // If metadata is missing (login screen doesn't pass it), use defaults.
    final appUser = AppUser(
      uid: uid,
      email: email.trim(),
      firstName: firstName ?? 'User',
      lastName: lastName ?? '',
      nationality: nationality ?? '',
      role: AppRoles.learner,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppCollections.users)
        .doc(uid)
        .set(appUser.toJson());

    return appUser;
  }

  // =========================================================================
  // RESEND — For users stuck in staging whose verification email got lost
  // =========================================================================

  Future<void> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.sendEmailVerification();
    await _auth.signOut();
  }

  // =========================================================================
  // MISC
  // =========================================================================

  Future<AppUser?> loadCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore
        .collection(AppCollections.users)
        .doc(user.uid)
        .get();
    if (!doc.exists) return null;
    return AppUser.fromJson(doc.data()!, uid: user.uid);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
}
