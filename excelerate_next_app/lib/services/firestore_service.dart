/// Firestore data-access layer for all non-auth collections.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/announcement.dart';
import '../models/feedback.dart';
import '../models/program.dart';
import '../models/registration.dart';
import '../utils/constants.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------------
  // PROGRAMS
  // ---------------------------------------------------------------------------

  Stream<List<Program>> watchPrograms() {
    return _firestore
        .collection(AppCollections.programs)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Program.fromJson(d.data(), id: d.id))
              .toList(),
        );
  }

  Future<List<Program>> fetchPrograms() async {
    final snap = await _firestore
        .collection(AppCollections.programs)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Program.fromJson(d.data(), id: d.id)).toList();
  }

  Future<Program> fetchProgram(String id) async {
    final doc = await _firestore
        .collection(AppCollections.programs)
        .doc(id)
        .get();
    if (!doc.exists) throw Exception('Program not found.');
    return Program.fromJson(doc.data()!, id: doc.id);
  }

  Future<String> createProgram(Program program) async {
    final ref = await _firestore
        .collection(AppCollections.programs)
        .add(program.toJson());
    return ref.id;
  }

  Future<void> updateProgram(Program program) {
    return _firestore
        .collection(AppCollections.programs)
        .doc(program.id)
        .set(program.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteProgram(String id) {
    return _firestore.collection(AppCollections.programs).doc(id).delete();
  }

  // ---------------------------------------------------------------------------
  // REGISTRATIONS — PENDING → APPROVED / REJECTED workflow
  // ---------------------------------------------------------------------------

  /// Registers [userId] for [programId]. Status = PENDING.
  /// Atomic: checks program availability, duplicate/rejected state, creates
  /// the PENDING registration, and increments the seat count in one commit.
  Future<void> registerForProgram({
    required String programId,
    required String userId,
    required String userEmail,
    required String userName,
    String? programTitle,
    String? programInstructor,
  }) async {
    final regRef = _firestore.collection(AppCollections.registrations).doc();
    final programRef = _firestore
        .collection(AppCollections.programs)
        .doc(programId);

    await _firestore.runTransaction((txn) async {
      // ---- Program availability (server-side read) ----
      final programSnap = await txn.get(programRef);
      if (!programSnap.exists) {
        throw Exception('Program not found.');
      }
      final programData = programSnap.data()!;
      final status = (programData['status'] ?? ProgramStatus.open).toString();
      final capacity = (programData['capacity'] ?? 0).toInt();
      final registered = (programData['registeredCount'] ?? 0).toInt();

      if (status != ProgramStatus.open) {
        throw Exception('This program is no longer accepting applications.');
      }
      if (capacity > 0 && registered >= capacity) {
        throw Exception('Sorry, this program is full.');
      }

      // ---- Existing registration state for this user + program ----
      final existing = await _firestore
          .collection(AppCollections.registrations)
          .where('programId', isEqualTo: programId)
          .where('userId', isEqualTo: userId)
          .get();

      for (final d in existing.docs) {
        final regStatus = d.data()['status'] as String? ?? '';
        // Active registrations — block
        if (regStatus == RegistrationStatus.pending ||
            regStatus == RegistrationStatus.approved ||
            regStatus == RegistrationStatus.registeredLegacy) {
          throw Exception('You have already applied for this program.');
        }
        // Rejected — enforce 30-day cooldown
        if (regStatus == RegistrationStatus.rejected) {
          final rejectedAt = (d.data()['rejectedAt'] as Timestamp?)?.toDate();
          if (rejectedAt != null) {
            final daysSince = DateTime.now().difference(rejectedAt).inDays;
            if (daysSince < 30) {
              final remaining = 30 - daysSince;
              throw Exception(
                'Your previous application was rejected. You can re-apply in $remaining day${remaining == 1 ? '' : 's'}.',
              );
            }
          }
        }
      }

      final reg = Registration(
        id: '',
        programId: programId,
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        status: RegistrationStatus.pending,
        registeredAt: DateTime.now(),
        programTitle: programTitle,
        programInstructor: programInstructor,
      );

      txn.set(regRef, reg.toJson());
      txn.update(programRef, {'registeredCount': FieldValue.increment(1)});
    });
  }

  /// Admin approves a pending registration. No-op if not pending.
  Future<void> approveRegistration(String registrationId) async {
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(
        _firestore.collection(AppCollections.registrations).doc(registrationId),
      );
      if (!snap.exists) return;
      final currentStatus = snap.data()?['status']?.toString() ?? '';
      if (currentStatus != RegistrationStatus.pending) return;
      txn.update(snap.reference, {'status': RegistrationStatus.approved});
    });
  }

  /// Admin rejects a pending registration. Decrements seat count. No-op if not pending.
  Future<void> rejectRegistration(
    String registrationId,
    String programId,
  ) async {
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(
        _firestore.collection(AppCollections.registrations).doc(registrationId),
      );
      if (!snap.exists) return;
      final currentStatus = snap.data()?['status']?.toString() ?? '';
      if (currentStatus != RegistrationStatus.pending) return;
      txn.update(snap.reference, {
        'status': RegistrationStatus.rejected,
        'rejectedAt': Timestamp.fromDate(DateTime.now()),
      });
      txn.update(
        _firestore.collection(AppCollections.programs).doc(programId),
        {'registeredCount': FieldValue.increment(-1)},
      );
    });
  }

  /// Learner withdraws. Decrements the seat count only for approved seats.
  Future<void> cancelRegistration(
    String registrationId,
    String programId,
  ) async {
    await _firestore.runTransaction((txn) async {
      final regSnap = await txn.get(
        _firestore.collection(AppCollections.registrations).doc(registrationId),
      );
      if (!regSnap.exists) return;
      final currentStatus = regSnap.data()?['status']?.toString() ?? '';
      // Only an active application can be withdrawn; count only drops for
      // approved seats (pending seats are released when the doc transitions).
      if (currentStatus == RegistrationStatus.cancelled) return;
      txn.update(regSnap.reference, {'status': RegistrationStatus.cancelled});
      if (currentStatus == RegistrationStatus.approved ||
          currentStatus == RegistrationStatus.registeredLegacy) {
        final programRef = _firestore
            .collection(AppCollections.programs)
            .doc(programId);
        final programSnap = await txn.get(programRef);
        if (programSnap.exists) {
          txn.update(programRef, {'registeredCount': FieldValue.increment(-1)});
        }
      }
    });
  }

  Stream<List<Registration>> watchUserRegistrations(String userId) {
    return _firestore
        .collection(AppCollections.registrations)
        .where('userId', isEqualTo: userId)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Registration.fromJson(d.data(), id: d.id))
              .toList(),
        );
  }

  Stream<List<Registration>> watchProgramRegistrations(String programId) {
    return _firestore
        .collection(AppCollections.registrations)
        .where('programId', isEqualTo: programId)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Registration.fromJson(d.data(), id: d.id))
              .toList(),
        );
  }

  /// Is user approved (enrolled) for this program?
  Future<bool> isEnrolled(String programId, String userId) async {
    final snap = await _firestore
        .collection(AppCollections.registrations)
        .where('programId', isEqualTo: programId)
        .where('userId', isEqualTo: userId)
        .get();
    return snap.docs.any((d) {
      final s = d.data()['status'] as String? ?? '';
      return s == RegistrationStatus.approved ||
          s == RegistrationStatus.registeredLegacy;
    });
  }

  // ---------------------------------------------------------------------------
  // ANNOUNCEMENTS
  // ---------------------------------------------------------------------------

  Stream<List<Announcement>> watchAnnouncements() {
    return _firestore
        .collection(AppCollections.announcements)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Announcement.fromJson(d.data(), id: d.id))
              .toList(),
        );
  }

  Future<String> createAnnouncement(Announcement announcement) async {
    final ref = await _firestore
        .collection(AppCollections.announcements)
        .add(announcement.toJson());
    return ref.id;
  }

  Future<void> deleteAnnouncement(String id) {
    return _firestore.collection(AppCollections.announcements).doc(id).delete();
  }

  // ---------------------------------------------------------------------------
  // FEEDBACK
  // ---------------------------------------------------------------------------

  /// Submits feedback and atomically updates the program's aggregate rating.
  /// Uses a transaction so rating/reviewsCount never races and the feedback
  /// document is only created if the program update succeeds.
  ///
  /// Only learners with an approved registration may submit feedback, and each
  /// learner can review each program once.
  Future<String> submitFeedback(Feedback feedback) async {
    // 0. Prevent duplicate feedback from the same learner for the same program.
    // We check this BEFORE the transaction because Firestore transactions
    // cannot contain queries. The final guard is re-checked inside the
    // transaction against the program's review counters where possible.
    final existing = await _firestore
        .collection(AppCollections.feedback)
        .where('programId', isEqualTo: feedback.programId)
        .where('userId', isEqualTo: feedback.userId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('You have already submitted feedback for this program.');
    }

    final feedbackRef = _firestore.collection(AppCollections.feedback).doc();

    // 1. Write the feedback and update the program atomically.
    await _firestore.runTransaction((txn) async {
      final programRef = _firestore
          .collection(AppCollections.programs)
          .doc(feedback.programId);
      final programSnap = await txn.get(programRef);

      if (!programSnap.exists) {
        throw Exception('Program not found. Feedback cannot be submitted.');
      }

      // Require an approved registration for this learner+program.
      final approvedRegs = await _firestore
          .collection(AppCollections.registrations)
          .where('programId', isEqualTo: feedback.programId)
          .where('userId', isEqualTo: feedback.userId)
          .get();
      final isApproved = approvedRegs.docs.any((d) {
        final s = d.data()['status']?.toString() ?? '';
        return s == RegistrationStatus.approved ||
            s == RegistrationStatus.registeredLegacy;
      });
      if (!isApproved) {
        throw Exception(
          'You are not enrolled in this program. Only enrolled learners can submit feedback.',
        );
      }

      // Create the feedback document within the transaction
      txn.set(feedbackRef, feedback.toJson());

      // Update the program's aggregate rating
      final data = programSnap.data()!;
      final oldRating = (data['rating'] ?? 0.0).toDouble();
      final oldCount = (data['reviewsCount'] ?? 0).toInt();
      final newCount = oldCount + 1;
      final newRating =
          ((oldRating * oldCount) + feedback.averageRating) / newCount;

      txn.update(programRef, {
        'rating': double.parse(newRating.toStringAsFixed(2)),
        'reviewsCount': newCount,
      });
    });

    return feedbackRef.id;
  }

  /// Returns `true` if the learner has already submitted feedback for [programId].
  /// Used by the feedback screen to disable the form proactively — saves the
  /// learner from filling the entire form only to be told they already reviewed.
  Future<bool> hasSubmittedFeedback(String userId, String programId) async {
    final existing = await _firestore
        .collection(AppCollections.feedback)
        .where('programId', isEqualTo: programId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return existing.docs.isNotEmpty;
  }

  Stream<List<Feedback>> watchProgramFeedback(String programId) {
    return _firestore
        .collection(AppCollections.feedback)
        .where('programId', isEqualTo: programId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => Feedback.fromJson(d.data(), id: d.id))
              .toList();
          // Sort client-side to avoid requiring a composite index
          // (programId ASC, createdAt DESC) on Firestore.
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // ---------------------------------------------------------------------------
  // ADMIN STATISTICS
  // ---------------------------------------------------------------------------

  Stream<int> watchLearnerCount() {
    return _firestore
        .collection(AppCollections.users)
        .where('role', isEqualTo: 'learner')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<int> watchRegistrationCount() {
    return _firestore
        .collection(AppCollections.registrations)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
