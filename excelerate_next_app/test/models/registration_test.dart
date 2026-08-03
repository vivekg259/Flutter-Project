import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_next_app/models/registration.dart';

void main() {
  group('Registration', () {
    final now = DateTime(2026, 7, 15, 10, 30);
    final timestamp = Timestamp.fromDate(now);

    Map<String, dynamic> fullJson() => {
      'programId': 'prog1',
      'userId': 'user1',
      'userEmail': 'learner@example.com',
      'userName': 'Jane Doe',
      'status': RegistrationStatus.approved,
      'registeredAt': timestamp,
      'rejectedAt': null,
      'programTitle': 'Flutter Basics',
      'programInstructor': 'Dr. Smith',
    };

    // ---------------------------------------------------------------
    // fromJson
    // ---------------------------------------------------------------
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final r = Registration.fromJson(fullJson(), id: 'reg1');

        expect(r.id, 'reg1');
        expect(r.programId, 'prog1');
        expect(r.userId, 'user1');
        expect(r.userEmail, 'learner@example.com');
        expect(r.userName, 'Jane Doe');
        expect(r.status, RegistrationStatus.approved);
        expect(r.registeredAt, now);
        expect(r.rejectedAt, isNull);
        expect(r.programTitle, 'Flutter Basics');
        expect(r.programInstructor, 'Dr. Smith');
      });

      test('applies defaults for missing fields', () {
        final r = Registration.fromJson({}, id: 'reg2');

        expect(r.id, 'reg2');
        expect(r.programId, '');
        expect(r.userId, '');
        expect(r.userEmail, '');
        expect(r.userName, '');
        expect(r.status, RegistrationStatus.pending);
        expect(r.rejectedAt, isNull);
        expect(r.programTitle, isNull);
        expect(r.programInstructor, isNull);
      });

      test('uses json id when no explicit id is given', () {
        final r = Registration.fromJson({'id': 'fromJson'});
        expect(r.id, 'fromJson');
      });

      test('parses rejectedAt timestamp', () {
        final rejTime = DateTime(2026, 6, 1);
        final r = Registration.fromJson({
          'rejectedAt': Timestamp.fromDate(rejTime),
          'registeredAt': timestamp,
        }, id: 'reg3');

        expect(r.rejectedAt, rejTime);
      });
    });

    // ---------------------------------------------------------------
    // toJson
    // ---------------------------------------------------------------
    group('toJson', () {
      test('serializes all fields correctly', () {
        final r = Registration(
          id: 'reg',
          programId: 'prog1',
          userId: 'user1',
          userEmail: 'e@e.com',
          userName: 'Name',
          status: RegistrationStatus.pending,
          registeredAt: now,
          programTitle: 'Title',
          programInstructor: 'Instructor',
        );
        final json = r.toJson();

        expect(json['programId'], 'prog1');
        expect(json['userId'], 'user1');
        expect(json['userEmail'], 'e@e.com');
        expect(json['userName'], 'Name');
        expect(json['status'], RegistrationStatus.pending);
        expect(json['registeredAt'], isA<Timestamp>());
        expect(json['programTitle'], 'Title');
        expect(json['programInstructor'], 'Instructor');
        expect(json.containsKey('id'), isFalse);
      });

      test('omits null optional fields', () {
        final r = Registration(
          id: 'reg',
          programId: 'p',
          userId: 'u',
          userEmail: 'e',
          userName: 'n',
          registeredAt: now,
        );
        final json = r.toJson();

        expect(json.containsKey('rejectedAt'), isFalse);
        expect(json.containsKey('programTitle'), isFalse);
        expect(json.containsKey('programInstructor'), isFalse);
      });

      test('includes rejectedAt when present', () {
        final rejTime = DateTime(2026, 6, 1);
        final r = Registration(
          id: 'reg',
          programId: 'p',
          userId: 'u',
          userEmail: 'e',
          userName: 'n',
          registeredAt: now,
          rejectedAt: rejTime,
        );
        final json = r.toJson();

        expect(json.containsKey('rejectedAt'), isTrue);
        expect(json['rejectedAt'], isA<Timestamp>());
      });
    });

    // ---------------------------------------------------------------
    // Round-trip
    // ---------------------------------------------------------------
    test('fromJson → toJson → fromJson round-trip', () {
      final original = Registration.fromJson(fullJson(), id: 'rt');
      final rebuilt = Registration.fromJson(original.toJson(), id: 'rt');

      expect(rebuilt.programId, original.programId);
      expect(rebuilt.userId, original.userId);
      expect(rebuilt.userEmail, original.userEmail);
      expect(rebuilt.userName, original.userName);
      expect(rebuilt.status, original.status);
      expect(rebuilt.registeredAt, original.registeredAt);
    });

    // ---------------------------------------------------------------
    // copyWith
    // ---------------------------------------------------------------
    group('copyWith', () {
      test('overrides specified fields only', () {
        final r = Registration.fromJson(fullJson(), id: 'cw');
        final rejTime = DateTime(2026, 8, 1);
        final copy = r.copyWith(
          status: RegistrationStatus.rejected,
          rejectedAt: rejTime,
        );

        expect(copy.status, RegistrationStatus.rejected);
        expect(copy.rejectedAt, rejTime);
        // Unchanged
        expect(copy.id, 'cw');
        expect(copy.programId, r.programId);
        expect(copy.userId, r.userId);
        expect(copy.userName, r.userName);
        expect(copy.registeredAt, r.registeredAt);
      });

      test('returns identical data when no arguments provided', () {
        final r = Registration.fromJson(fullJson(), id: 'cw2');
        final copy = r.copyWith();

        expect(copy.status, r.status);
        expect(copy.rejectedAt, r.rejectedAt);
        expect(copy.programId, r.programId);
      });
    });

    // ---------------------------------------------------------------
    // Status predicates
    // ---------------------------------------------------------------
    group('status predicates', () {
      Registration withStatus(String status, {DateTime? rejectedAt}) =>
          Registration(
            id: 'r',
            programId: 'p',
            userId: 'u',
            userEmail: 'e',
            userName: 'n',
            status: status,
            registeredAt: now,
            rejectedAt: rejectedAt,
          );

      test('isPending', () {
        expect(withStatus(RegistrationStatus.pending).isPending, isTrue);
        expect(withStatus(RegistrationStatus.approved).isPending, isFalse);
      });

      test('isApproved for APPROVED status', () {
        expect(withStatus(RegistrationStatus.approved).isApproved, isTrue);
        expect(withStatus(RegistrationStatus.pending).isApproved, isFalse);
      });

      test('isApproved for legacy "registered" status', () {
        expect(
          withStatus(RegistrationStatus.registeredLegacy).isApproved,
          isTrue,
        );
      });

      test('isEnrolled matches isApproved', () {
        expect(withStatus(RegistrationStatus.approved).isEnrolled, isTrue);
        expect(
          withStatus(RegistrationStatus.registeredLegacy).isEnrolled,
          isTrue,
        );
        expect(withStatus(RegistrationStatus.pending).isEnrolled, isFalse);
      });

      test('isRejected', () {
        expect(withStatus(RegistrationStatus.rejected).isRejected, isTrue);
        expect(withStatus(RegistrationStatus.approved).isRejected, isFalse);
      });

      test('isCancelled', () {
        expect(withStatus(RegistrationStatus.cancelled).isCancelled, isTrue);
        expect(withStatus(RegistrationStatus.approved).isCancelled, isFalse);
      });

      test('isVisible — all except cancelled', () {
        expect(withStatus(RegistrationStatus.pending).isVisible, isTrue);
        expect(withStatus(RegistrationStatus.approved).isVisible, isTrue);
        expect(withStatus(RegistrationStatus.rejected).isVisible, isTrue);
        expect(withStatus(RegistrationStatus.cancelled).isVisible, isFalse);
      });
    });

    // ---------------------------------------------------------------
    // Reapply logic
    // ---------------------------------------------------------------
    group('reapply logic', () {
      test('canReapply false when not rejected', () {
        final r = Registration(
          id: 'r',
          programId: 'p',
          userId: 'u',
          userEmail: 'e',
          userName: 'n',
          status: RegistrationStatus.approved,
          registeredAt: now,
        );
        expect(r.canReapply, isFalse);
      });

      test('canReapply true when rejected with no rejectedAt', () {
        final r = Registration(
          id: 'r',
          programId: 'p',
          userId: 'u',
          userEmail: 'e',
          userName: 'n',
          status: RegistrationStatus.rejected,
          registeredAt: now,
          rejectedAt: null,
        );
        expect(r.canReapply, isTrue);
      });

      test('canReapply false within 30 days of rejection', () {
        final r = Registration(
          id: 'r',
          programId: 'p',
          userId: 'u',
          userEmail: 'e',
          userName: 'n',
          status: RegistrationStatus.rejected,
          registeredAt: now,
          rejectedAt: DateTime.now().subtract(const Duration(days: 10)),
        );
        expect(r.canReapply, isFalse);
      });

      test('canReapply true after 30 days', () {
        final r = Registration(
          id: 'r',
          programId: 'p',
          userId: 'u',
          userEmail: 'e',
          userName: 'n',
          status: RegistrationStatus.rejected,
          registeredAt: now,
          rejectedAt: DateTime.now().subtract(const Duration(days: 31)),
        );
        expect(r.canReapply, isTrue);
      });

      test('canReapply true at exactly 30 days', () {
        final r = Registration(
          id: 'r',
          programId: 'p',
          userId: 'u',
          userEmail: 'e',
          userName: 'n',
          status: RegistrationStatus.rejected,
          registeredAt: now,
          rejectedAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(r.canReapply, isTrue);
      });

      test('daysUntilReapply returns correct remaining days', () {
        final r = Registration(
          id: 'r',
          programId: 'p',
          userId: 'u',
          userEmail: 'e',
          userName: 'n',
          status: RegistrationStatus.rejected,
          registeredAt: now,
          rejectedAt: DateTime.now().subtract(const Duration(days: 10)),
        );
        expect(r.daysUntilReapply, 20);
      });

      test('daysUntilReapply returns 0 when cooldown expired', () {
        final r = Registration(
          id: 'r',
          programId: 'p',
          userId: 'u',
          userEmail: 'e',
          userName: 'n',
          status: RegistrationStatus.rejected,
          registeredAt: now,
          rejectedAt: DateTime.now().subtract(const Duration(days: 45)),
        );
        expect(r.daysUntilReapply, 0);
      });

      test('daysUntilReapply returns 0 when rejectedAt is null', () {
        final r = Registration(
          id: 'r',
          programId: 'p',
          userId: 'u',
          userEmail: 'e',
          userName: 'n',
          status: RegistrationStatus.rejected,
          registeredAt: now,
          rejectedAt: null,
        );
        expect(r.daysUntilReapply, 0);
      });
    });

    // ---------------------------------------------------------------
    // RegistrationStatus constants
    // ---------------------------------------------------------------
    group('RegistrationStatus constants', () {
      test('has correct string values', () {
        expect(RegistrationStatus.pending, 'PENDING');
        expect(RegistrationStatus.approved, 'APPROVED');
        expect(RegistrationStatus.rejected, 'REJECTED');
        expect(RegistrationStatus.cancelled, 'CANCELLED');
        expect(RegistrationStatus.registeredLegacy, 'registered');
      });
    });
  });
}
