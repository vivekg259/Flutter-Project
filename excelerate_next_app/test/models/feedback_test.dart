import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_next_app/models/feedback.dart' as app_fb;

void main() {
  group('Feedback Model', () {
    final now = DateTime(2026, 7, 15, 10, 30);
    final timestamp = Timestamp.fromDate(now);

    Map<String, dynamic> fullJson() => {
      'programId': 'prog100',
      'userId': 'user200',
      'contentRating': 5,
      'instructorRating': 4,
      'overallRating': 4.5,
      'pace': app_fb.FeedbackPace.justRight,
      'review': 'Great program, highly recommended!',
      'userName': 'John Doe',
      'userEmail': 'john@example.com',
      'programTitle': 'Flutter Dev',
      'createdAt': timestamp,
    };

    // ---------------------------------------------------------------
    // fromJson
    // ---------------------------------------------------------------
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final fb = app_fb.Feedback.fromJson(fullJson(), id: 'fb1');

        expect(fb.id, 'fb1');
        expect(fb.programId, 'prog100');
        expect(fb.userId, 'user200');
        expect(fb.contentRating, 5);
        expect(fb.instructorRating, 4);
        expect(fb.pace, app_fb.FeedbackPace.justRight);
        expect(fb.review, 'Great program, highly recommended!');
        expect(fb.userName, 'John Doe');
        expect(fb.userEmail, 'john@example.com');
        expect(fb.programTitle, 'Flutter Dev');
        expect(fb.createdAt, now);
      });

      test('applies defaults for missing optional fields', () {
        final fb = app_fb.Feedback.fromJson({}, id: 'fb2');

        expect(fb.id, 'fb2');
        expect(fb.programId, '');
        expect(fb.userId, '');
        expect(fb.contentRating, 1); // clamped from 0
        expect(fb.instructorRating, 1); // clamped from 0
        expect(fb.pace, app_fb.FeedbackPace.justRight);
        expect(fb.review, '');
        expect(fb.userName, isNull);
        expect(fb.userEmail, isNull);
        expect(fb.programTitle, isNull);
      });

      test('clamps ratings within 1-5 range', () {
        final fbLow = app_fb.Feedback.fromJson({
          'contentRating': -2,
          'instructorRating': 0,
        });
        expect(fbLow.contentRating, 1);
        expect(fbLow.instructorRating, 1);

        final fbHigh = app_fb.Feedback.fromJson({
          'contentRating': 10,
          'instructorRating': 99,
        });
        expect(fbHigh.contentRating, 5);
        expect(fbHigh.instructorRating, 5);
      });

      test('uses json id when no explicit id is given', () {
        final fb = app_fb.Feedback.fromJson({'id': 'json_id'});
        expect(fb.id, 'json_id');
      });
    });

    // ---------------------------------------------------------------
    // toJson
    // ---------------------------------------------------------------
    group('toJson', () {
      test('serializes fields correctly and includes overallRating', () {
        final fb = app_fb.Feedback(
          id: 'fb1',
          programId: 'prog1',
          userId: 'user1',
          contentRating: 4,
          instructorRating: 5,
          pace: app_fb.FeedbackPace.tooFast,
          review: 'Very fast paced',
          userName: 'Alice',
          userEmail: 'alice@test.com',
          programTitle: 'Fast Track',
          createdAt: now,
        );

        final json = fb.toJson();

        expect(json['programId'], 'prog1');
        expect(json['userId'], 'user1');
        expect(json['contentRating'], 4);
        expect(json['instructorRating'], 5);
        expect(json['overallRating'], 4.5); // Derived average rating
        expect(json['pace'], app_fb.FeedbackPace.tooFast);
        expect(json['review'], 'Very fast paced');
        expect(json['userName'], 'Alice');
        expect(json['userEmail'], 'alice@test.com');
        expect(json['programTitle'], 'Fast Track');
        expect(json['createdAt'], isA<Timestamp>());
        expect(json.containsKey('id'), isFalse);
      });

      test('omits null optional fields in toJson', () {
        final fb = app_fb.Feedback(
          id: 'fb1',
          programId: 'p',
          userId: 'u',
          contentRating: 3,
          instructorRating: 3,
          pace: app_fb.FeedbackPace.justRight,
          review: 'OK',
          createdAt: now,
        );

        final json = fb.toJson();

        expect(json.containsKey('userName'), isFalse);
        expect(json.containsKey('userEmail'), isFalse);
        expect(json.containsKey('programTitle'), isFalse);
      });
    });

    // ---------------------------------------------------------------
    // Computed Properties & copyWith
    // ---------------------------------------------------------------
    group('computed properties & copyWith', () {
      test(
        'averageRating computes correct mean of content and instructor rating',
        () {
          final fb = app_fb.Feedback(
            id: 'fb',
            programId: 'p',
            userId: 'u',
            contentRating: 4,
            instructorRating: 5,
            pace: app_fb.FeedbackPace.justRight,
            review: 'Nice',
            createdAt: now,
          );

          expect(fb.averageRating, 4.5);
        },
      );

      test('copyWith overrides specified fields correctly', () {
        final fb = app_fb.Feedback.fromJson(fullJson(), id: 'orig');
        final updated = fb.copyWith(contentRating: 3, review: 'Updated review');

        expect(updated.id, 'orig');
        expect(updated.contentRating, 3);
        expect(updated.instructorRating, 4); // Unchanged
        expect(updated.review, 'Updated review');
        expect(updated.averageRating, 3.5);
      });
    });

    // ---------------------------------------------------------------
    // FeedbackPace Constants
    // ---------------------------------------------------------------
    group('FeedbackPace constants', () {
      test('defines expected pace values', () {
        expect(app_fb.FeedbackPace.tooSlow, 'too_slow');
        expect(app_fb.FeedbackPace.justRight, 'just_right');
        expect(app_fb.FeedbackPace.tooFast, 'too_fast');
      });
    });
  });
}
