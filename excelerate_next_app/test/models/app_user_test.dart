import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_next_app/models/app_user.dart';
import 'package:excelerate_next_app/utils/constants.dart';

void main() {
  group('AppUser', () {
    final now = DateTime(2026, 7, 15, 10, 30);
    final timestamp = Timestamp.fromDate(now);

    Map<String, dynamic> fullJson() => {
      'email': 'vivek@example.com',
      'firstName': 'Vivek',
      'lastName': 'Gupta',
      'role': 'admin',
      'nationality': 'Indian',
      'photoUrl': 'https://example.com/photo.jpg',
      'createdAt': timestamp,
    };

    // ---------------------------------------------------------------
    // fromJson
    // ---------------------------------------------------------------
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final user = AppUser.fromJson(fullJson(), uid: 'uid123');

        expect(user.uid, 'uid123');
        expect(user.email, 'vivek@example.com');
        expect(user.firstName, 'Vivek');
        expect(user.lastName, 'Gupta');
        expect(user.role, 'admin');
        expect(user.nationality, 'Indian');
        expect(user.photoUrl, 'https://example.com/photo.jpg');
        expect(user.createdAt, now);
      });

      test('applies defaults for missing optional fields', () {
        final user = AppUser.fromJson({'createdAt': timestamp}, uid: 'uid456');

        expect(user.uid, 'uid456');
        expect(user.email, '');
        expect(user.firstName, '');
        expect(user.lastName, '');
        expect(user.role, AppRoles.learner);
        expect(user.nationality, '');
        expect(user.photoUrl, isNull);
      });

      test('defaults createdAt to now when Timestamp is null', () {
        final before = DateTime.now();
        final user = AppUser.fromJson({}, uid: 'uid789');
        final after = DateTime.now();

        expect(
          user.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          user.createdAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue,
        );
      });

      test('converts non-string values via toString()', () {
        final user = AppUser.fromJson({
          'email': 123,
          'firstName': true,
          'lastName': 456.78,
          'role': null, // should fall back to learner default
          'createdAt': timestamp,
        }, uid: 'uid');

        expect(user.email, '123');
        expect(user.firstName, 'true');
        expect(user.lastName, '456.78');
        expect(user.role, AppRoles.learner);
      });
    });

    // ---------------------------------------------------------------
    // toJson
    // ---------------------------------------------------------------
    group('toJson', () {
      test('serializes all fields correctly', () {
        final user = AppUser(
          uid: 'uid123',
          email: 'test@test.com',
          firstName: 'Alice',
          lastName: 'Smith',
          role: AppRoles.learner,
          nationality: 'US',
          photoUrl: 'https://photo.url',
          createdAt: now,
        );
        final json = user.toJson();

        expect(json['email'], 'test@test.com');
        expect(json['firstName'], 'Alice');
        expect(json['lastName'], 'Smith');
        expect(json['role'], AppRoles.learner);
        expect(json['nationality'], 'US');
        expect(json['photoUrl'], 'https://photo.url');
        expect(json['createdAt'], isA<Timestamp>());
        // uid is NOT in toJson — it's the doc ID
        expect(json.containsKey('uid'), isFalse);
      });

      test('omits photoUrl when null', () {
        final user = AppUser(
          uid: 'uid',
          email: 'e',
          firstName: 'f',
          lastName: 'l',
          createdAt: now,
        );
        final json = user.toJson();

        expect(json.containsKey('photoUrl'), isFalse);
      });
    });

    // ---------------------------------------------------------------
    // Round-trip
    // ---------------------------------------------------------------
    test('fromJson → toJson → fromJson round-trip preserves data', () {
      final original = AppUser.fromJson(fullJson(), uid: 'rt');
      final rebuilt = AppUser.fromJson(original.toJson(), uid: 'rt');

      expect(rebuilt.uid, original.uid);
      expect(rebuilt.email, original.email);
      expect(rebuilt.firstName, original.firstName);
      expect(rebuilt.lastName, original.lastName);
      expect(rebuilt.role, original.role);
      expect(rebuilt.nationality, original.nationality);
      expect(rebuilt.photoUrl, original.photoUrl);
      expect(rebuilt.createdAt, original.createdAt);
    });

    // ---------------------------------------------------------------
    // copyWith
    // ---------------------------------------------------------------
    group('copyWith', () {
      test('overrides specified fields only', () {
        final user = AppUser.fromJson(fullJson(), uid: 'cw');
        final copy = user.copyWith(firstName: 'Bob', role: AppRoles.learner);

        expect(copy.firstName, 'Bob');
        expect(copy.role, AppRoles.learner);
        // Unchanged fields
        expect(copy.uid, 'cw');
        expect(copy.email, user.email);
        expect(copy.lastName, user.lastName);
        expect(copy.nationality, user.nationality);
        expect(copy.createdAt, user.createdAt);
      });

      test('returns identical data when no arguments provided', () {
        final user = AppUser.fromJson(fullJson(), uid: 'cw2');
        final copy = user.copyWith();

        expect(copy.uid, user.uid);
        expect(copy.email, user.email);
        expect(copy.firstName, user.firstName);
        expect(copy.lastName, user.lastName);
        expect(copy.role, user.role);
      });
    });

    // ---------------------------------------------------------------
    // Computed properties
    // ---------------------------------------------------------------
    group('computed properties', () {
      test('fullName joins first and last names', () {
        final user = AppUser(
          uid: 'u',
          email: 'e',
          firstName: 'Vivek',
          lastName: 'Gupta',
          createdAt: now,
        );
        expect(user.fullName, 'Vivek Gupta');
      });

      test('fullName trims when last name is empty', () {
        final user = AppUser(
          uid: 'u',
          email: 'e',
          firstName: 'Vivek',
          lastName: '',
          createdAt: now,
        );
        expect(user.fullName, 'Vivek');
      });

      test('initials returns first characters of first and last name', () {
        final user = AppUser(
          uid: 'u',
          email: 'e',
          firstName: 'Vivek',
          lastName: 'Gupta',
          createdAt: now,
        );
        expect(user.initials, 'VG');
      });

      test('initials returns single letter when only first name', () {
        final user = AppUser(
          uid: 'u',
          email: 'e',
          firstName: 'Vivek',
          lastName: '',
          createdAt: now,
        );
        expect(user.initials, 'V');
      });

      test('initials returns ? when both names empty', () {
        final user = AppUser(
          uid: 'u',
          email: 'e',
          firstName: '',
          lastName: '',
          createdAt: now,
        );
        expect(user.initials, '?');
      });

      test('isAdmin returns true for admin role', () {
        final user = AppUser(
          uid: 'u',
          email: 'e',
          firstName: 'f',
          lastName: 'l',
          role: AppRoles.admin,
          createdAt: now,
        );
        expect(user.isAdmin, isTrue);
        expect(user.isLearner, isFalse);
      });

      test('isLearner returns true for learner role', () {
        final user = AppUser(
          uid: 'u',
          email: 'e',
          firstName: 'f',
          lastName: 'l',
          role: AppRoles.learner,
          createdAt: now,
        );
        expect(user.isLearner, isTrue);
        expect(user.isAdmin, isFalse);
      });
    });
  });
}
