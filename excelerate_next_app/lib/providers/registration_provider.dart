/// Tracks the signed-in learner's registrations.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/program.dart';
import '../models/registration.dart';
import '../services/firestore_service.dart';
import '../utils/helpers.dart';

class RegistrationProvider extends ChangeNotifier {
  RegistrationProvider({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService();

  final FirestoreService _firestore;
  StreamSubscription<List<Registration>>? _sub;

  List<Registration> _registrations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Registration> get registrations => _registrations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Approved / enrolled registrations only.
  List<Registration> get enrolled =>
      _registrations.where((r) => r.isEnrolled).toList();

  /// Visible registrations (non-cancelled).
  List<Registration> get visible =>
      _registrations.where((r) => r.isVisible).toList();

  void bind(AppUser user) {
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();
    _sub = _firestore
        .watchUserRegistrations(user.uid)
        .listen(
          (items) {
            _registrations = items;
            _isLoading = false;
            notifyListeners();
          },
          onError: (_) {
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Is user registered (pending or approved) for this program?
  bool isRegisteredFor(String programId) => _registrations.any(
    (r) => r.programId == programId && (r.isPending || r.isApproved),
  );

  /// Is user enrolled (approved) for this program?
  bool isEnrolledFor(String programId) =>
      _registrations.any((r) => r.programId == programId && r.isEnrolled);

  /// Get the registration for a program, if any.
  Registration? registrationFor(String programId) {
    final idx = _registrations.indexWhere(
      (r) => r.programId == programId && r.isVisible,
    );
    return idx >= 0 ? _registrations[idx] : null;
  }

  /// Register for a program — creates PENDING registration.
  Future<void> register(AppUser user, Program program) async {
    try {
      await _firestore.registerForProgram(
        programId: program.id,
        userId: user.uid,
        userEmail: user.email,
        userName: user.fullName,
        programTitle: program.title,
        programInstructor: program.instructor,
      );
    } catch (e) {
      _errorMessage = friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancel(Registration registration) async {
    try {
      await _firestore.cancelRegistration(
        registration.id,
        registration.programId,
      );
    } catch (e) {
      _errorMessage = friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
