import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_next_app/models/program.dart';

void main() {
  group('Program', () {
    final now = DateTime(2026, 7, 15, 10, 30);
    final timestamp = Timestamp.fromDate(now);

    Map<String, dynamic> fullJson() => {
      'title': 'Flutter Masterclass',
      'description': 'Learn Flutter from scratch',
      'instructor': 'Dr. Smith',
      'duration': '8 weeks',
      'level': 'Intermediate',
      'skills': ['Flutter', 'Dart', 'Firebase'],
      'rating': 4.5,
      'reviewsCount': 120,
      'capacity': 50,
      'registeredCount': 30,
      'status': ProgramStatus.open,
      'registrationType': 'auto',
      'registrationStartDate': timestamp,
      'eligibility': 'Basic Dart knowledge',
      'schedule': 'Mon/Wed/Fri 10 AM',
      'imageUrl': 'https://example.com/img.png',
      'createdBy': 'admin123',
      'publishAt': timestamp,
      'createdAt': timestamp,
    };

    // ---------------------------------------------------------------
    // fromJson
    // ---------------------------------------------------------------
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final p = Program.fromJson(fullJson(), id: 'p1');

        expect(p.id, 'p1');
        expect(p.title, 'Flutter Masterclass');
        expect(p.description, 'Learn Flutter from scratch');
        expect(p.instructor, 'Dr. Smith');
        expect(p.duration, '8 weeks');
        expect(p.level, 'Intermediate');
        expect(p.skills, ['Flutter', 'Dart', 'Firebase']);
        expect(p.rating, 4.5);
        expect(p.reviewsCount, 120);
        expect(p.capacity, 50);
        expect(p.registeredCount, 30);
        expect(p.status, ProgramStatus.open);
        expect(p.registrationType, 'auto');
        expect(p.registrationStartDate, now);
        expect(p.eligibility, 'Basic Dart knowledge');
        expect(p.schedule, 'Mon/Wed/Fri 10 AM');
        expect(p.imageUrl, 'https://example.com/img.png');
        expect(p.createdBy, 'admin123');
        expect(p.publishAt, now);
        expect(p.createdAt, now);
      });

      test('applies sensible defaults for missing fields', () {
        final p = Program.fromJson({}, id: 'p2');

        expect(p.id, 'p2');
        expect(p.title, 'Untitled Program');
        expect(p.description, 'No description available.');
        expect(p.instructor, 'Industry Specialist');
        expect(p.duration, 'Self-Paced');
        expect(p.level, 'All Levels');
        expect(p.skills, isEmpty);
        expect(p.rating, 0.0);
        expect(p.reviewsCount, 0);
        expect(p.capacity, 0);
        expect(p.registeredCount, 0);
        expect(p.status, ProgramStatus.open);
        expect(p.registrationType, isNull);
        expect(p.eligibility, isNull);
        expect(p.schedule, isNull);
        expect(p.imageUrl, isNull);
        expect(p.createdBy, isNull);
        expect(p.publishAt, isNull);
      });

      test('parses skills from comma-separated string', () {
        final p = Program.fromJson({
          'skills': 'Flutter, Dart, Firebase',
          'createdAt': timestamp,
        }, id: 'p3');

        expect(p.skills, ['Flutter', 'Dart', 'Firebase']);
      });

      test('handles empty skills string', () {
        final p = Program.fromJson({
          'skills': '',
          'createdAt': timestamp,
        }, id: 'p4');

        expect(p.skills, isEmpty);
      });

      test('parses skills from List', () {
        final p = Program.fromJson({
          'skills': ['A', 'B'],
          'createdAt': timestamp,
        }, id: 'p5');

        expect(p.skills, ['A', 'B']);
      });

      test('uses json id when no explicit id is given', () {
        final p = Program.fromJson({
          'id': 'fromJsonId',
          'createdAt': timestamp,
        });

        expect(p.id, 'fromJsonId');
      });

      test('falls back to empty string when both ids are missing', () {
        final p = Program.fromJson({'createdAt': timestamp});
        expect(p.id, '');
      });

      test('converts numeric values correctly', () {
        final p = Program.fromJson({
          'rating': 3, // int, should become double
          'reviewsCount': 5.7, // double, should become int
          'capacity': 100.0, // double, should become int
          'createdAt': timestamp,
        }, id: 'p6');

        expect(p.rating, 3.0);
        expect(p.reviewsCount, 5);
        expect(p.capacity, 100);
      });
    });

    // ---------------------------------------------------------------
    // toJson
    // ---------------------------------------------------------------
    group('toJson', () {
      test('serializes all fields correctly', () {
        final p = Program.fromJson(fullJson(), id: 'pj');
        final json = p.toJson();

        expect(json['title'], 'Flutter Masterclass');
        expect(json['description'], 'Learn Flutter from scratch');
        expect(json['instructor'], 'Dr. Smith');
        expect(json['skills'], ['Flutter', 'Dart', 'Firebase']);
        expect(json['rating'], 4.5);
        expect(json['reviewsCount'], 120);
        expect(json['capacity'], 50);
        expect(json['registeredCount'], 30);
        expect(json['status'], ProgramStatus.open);
        expect(json['registrationType'], 'auto');
        expect(json['registrationStartDate'], isA<Timestamp>());
        expect(json['eligibility'], 'Basic Dart knowledge');
        expect(json['schedule'], 'Mon/Wed/Fri 10 AM');
        expect(json['imageUrl'], 'https://example.com/img.png');
        expect(json['createdBy'], 'admin123');
        expect(json['publishAt'], isA<Timestamp>());
        expect(json['createdAt'], isA<Timestamp>());
        // id is NOT in toJson — it's the doc ID
        expect(json.containsKey('id'), isFalse);
      });

      test('omits null optional fields', () {
        final p = Program(
          id: 'p',
          title: 'T',
          description: 'D',
          instructor: 'I',
          duration: 'D',
          level: 'L',
          skills: [],
          createdAt: now,
        );
        final json = p.toJson();

        expect(json.containsKey('eligibility'), isFalse);
        expect(json.containsKey('schedule'), isFalse);
        expect(json.containsKey('imageUrl'), isFalse);
        expect(json.containsKey('createdBy'), isFalse);
        expect(json.containsKey('publishAt'), isFalse);
        expect(json.containsKey('registrationType'), isFalse);
        expect(json.containsKey('registrationStartDate'), isFalse);
      });

      test('includes optional fields when present', () {
        final p = Program(
          id: 'p',
          title: 'T',
          description: 'D',
          instructor: 'I',
          duration: 'D',
          level: 'L',
          skills: [],
          eligibility: 'Basic',
          schedule: 'Daily',
          imageUrl: 'url',
          createdBy: 'admin',
          publishAt: now,
          createdAt: now,
        );
        final json = p.toJson();

        expect(json['eligibility'], 'Basic');
        expect(json['schedule'], 'Daily');
        expect(json['imageUrl'], 'url');
        expect(json['createdBy'], 'admin');
        expect(json['publishAt'], isA<Timestamp>());
      });
    });

    // ---------------------------------------------------------------
    // Round-trip
    // ---------------------------------------------------------------
    test('fromJson → toJson → fromJson round-trip', () {
      final original = Program.fromJson(fullJson(), id: 'rt');
      final rebuilt = Program.fromJson(original.toJson(), id: 'rt');

      expect(rebuilt.title, original.title);
      expect(rebuilt.instructor, original.instructor);
      expect(rebuilt.skills, original.skills);
      expect(rebuilt.rating, original.rating);
      expect(rebuilt.reviewsCount, original.reviewsCount);
      expect(rebuilt.capacity, original.capacity);
      expect(rebuilt.status, original.status);
      expect(rebuilt.registrationType, original.registrationType);
      expect(rebuilt.registrationStartDate, original.registrationStartDate);
      expect(rebuilt.eligibility, original.eligibility);
      expect(rebuilt.schedule, original.schedule);
      expect(rebuilt.imageUrl, original.imageUrl);
      expect(rebuilt.createdBy, original.createdBy);
      expect(rebuilt.publishAt, original.publishAt);
      expect(rebuilt.createdAt, original.createdAt);
    });

    // ---------------------------------------------------------------
    // copyWith
    // ---------------------------------------------------------------
    group('copyWith', () {
      test('overrides specified fields only', () {
        final p = Program.fromJson(fullJson(), id: 'cw');
        final copy = p.copyWith(title: 'New Title', capacity: 100);

        expect(copy.title, 'New Title');
        expect(copy.capacity, 100);
        // Unchanged
        expect(copy.id, 'cw');
        expect(copy.instructor, p.instructor);
        expect(copy.description, p.description);
        expect(copy.rating, p.rating);
        expect(copy.createdAt, p.createdAt);
        expect(copy.registrationType, p.registrationType);
        expect(copy.registrationStartDate, p.registrationStartDate);
        expect(copy.createdBy, p.createdBy);
        expect(copy.publishAt, p.publishAt);
      });

      test('overrides the round-tripped registration fields', () {
        final p = Program.fromJson(fullJson(), id: 'cw3');
        final copy = p.copyWith(
          registrationType: 'manual',
          registrationStartDate: now.add(const Duration(days: 5)),
        );

        expect(copy.registrationType, 'manual');
        expect(copy.registrationStartDate, now.add(const Duration(days: 5)));
        // Other fields unchanged
        expect(copy.publishAt, p.publishAt);
        expect(copy.createdBy, p.createdBy);
        expect(copy.capacity, p.capacity);
      });

      test('returns identical data when no arguments provided', () {
        final p = Program.fromJson(fullJson(), id: 'cw2');
        final copy = p.copyWith();

        expect(copy.title, p.title);
        expect(copy.description, p.description);
        expect(copy.capacity, p.capacity);
        expect(copy.status, p.status);
      });
    });

    // ---------------------------------------------------------------
    // Computed properties
    // ---------------------------------------------------------------
    group('computed properties', () {
      test('ratingDisplay formats correctly', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          rating: 4.567,
          reviewsCount: 42,
          createdAt: now,
        );
        expect(p.ratingDisplay, '4.6 (42 reviews)');
      });

      test('ratingShort returns dash when no reviews', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          rating: 0.0,
          reviewsCount: 0,
          createdAt: now,
        );
        expect(p.ratingShort, '—');
      });

      test('ratingShort returns formatted rating when reviews exist', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          rating: 4.75,
          reviewsCount: 10,
          createdAt: now,
        );
        expect(p.ratingShort, '4.8');
      });

      test('hasSeats returns true when capacity is 0 (unlimited)', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          capacity: 0,
          registeredCount: 999,
          createdAt: now,
        );
        expect(p.hasSeats, isTrue);
      });

      test('hasSeats returns true when registeredCount < capacity', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          capacity: 50,
          registeredCount: 30,
          createdAt: now,
        );
        expect(p.hasSeats, isTrue);
      });

      test('hasSeats returns false when full', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          capacity: 50,
          registeredCount: 50,
          createdAt: now,
        );
        expect(p.hasSeats, isFalse);
      });

      test('isRegistrationOpen when status=open and has seats', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          status: ProgramStatus.open,
          capacity: 50,
          registeredCount: 30,
          createdAt: now,
        );
        expect(p.isRegistrationOpen, isTrue);
      });

      test('isRegistrationOpen false when closed', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          status: ProgramStatus.closed,
          capacity: 50,
          registeredCount: 0,
          createdAt: now,
        );
        expect(p.isRegistrationOpen, isFalse);
      });

      test('isRegistrationOpen false when full', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          status: ProgramStatus.open,
          capacity: 50,
          registeredCount: 50,
          createdAt: now,
        );
        expect(p.isRegistrationOpen, isFalse);
      });

      test('isPublished true when publishAt is null', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          publishAt: null,
          createdAt: now,
        );
        expect(p.isPublished, isTrue);
      });

      test('isPublished true when publishAt is in the past', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          publishAt: DateTime.now().subtract(const Duration(hours: 1)),
          createdAt: now,
        );
        expect(p.isPublished, isTrue);
      });

      test('isPublished false when publishAt is in the future', () {
        final p = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          publishAt: DateTime.now().add(const Duration(days: 30)),
          createdAt: now,
        );
        expect(p.isPublished, isFalse);
      });

      test('registrationInfo returns correct strings', () {
        final closed = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          status: ProgramStatus.closed,
          createdAt: now,
        );
        expect(closed.registrationInfo, 'Registration Closed');

        final full = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          status: ProgramStatus.open,
          capacity: 10,
          registeredCount: 10,
          createdAt: now,
        );
        expect(full.registrationInfo, 'No seats left');

        final open = Program(
          id: 'p',
          title: 't',
          description: 'd',
          instructor: 'i',
          duration: '4w',
          level: 'L',
          skills: [],
          status: ProgramStatus.open,
          capacity: 10,
          registeredCount: 5,
          createdAt: now,
        );
        expect(open.registrationInfo, 'Open Now');
      });
    });

    // ---------------------------------------------------------------
    // Equality
    // ---------------------------------------------------------------
    group('equality', () {
      test('programs with same id are equal', () {
        final a = Program(
          id: 'same',
          title: 'A',
          description: '',
          instructor: '',
          duration: '',
          level: '',
          skills: [],
          createdAt: now,
        );
        final b = Program(
          id: 'same',
          title: 'B',
          description: '',
          instructor: '',
          duration: '',
          level: '',
          skills: [],
          createdAt: now,
        );
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('programs with different ids are not equal', () {
        final a = Program(
          id: 'a',
          title: 'T',
          description: '',
          instructor: '',
          duration: '',
          level: '',
          skills: [],
          createdAt: now,
        );
        final b = Program(
          id: 'b',
          title: 'T',
          description: '',
          instructor: '',
          duration: '',
          level: '',
          skills: [],
          createdAt: now,
        );
        expect(a, isNot(equals(b)));
      });
    });
  });
}
