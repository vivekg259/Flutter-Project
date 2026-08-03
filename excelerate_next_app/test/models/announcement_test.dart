import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_next_app/models/announcement.dart';

void main() {
  group('Announcement Model', () {
    final now = DateTime(2026, 7, 15, 10, 30);
    final timestamp = Timestamp.fromDate(now);

    Map<String, dynamic> fullJson() => {
      'title': 'System Maintenance',
      'body': 'Platform update scheduled for midnight.',
      'type': AnnouncementType.deadline,
      'priority': AnnouncementPriority.high,
      'programId': 'prog99',
      'createdBy': 'admin001',
      'createdAt': timestamp,
    };

    // ---------------------------------------------------------------
    // fromJson
    // ---------------------------------------------------------------
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final ann = Announcement.fromJson(fullJson(), id: 'ann1');

        expect(ann.id, 'ann1');
        expect(ann.title, 'System Maintenance');
        expect(ann.body, 'Platform update scheduled for midnight.');
        expect(ann.type, AnnouncementType.deadline);
        expect(ann.priority, AnnouncementPriority.high);
        expect(ann.programId, 'prog99');
        expect(ann.createdBy, 'admin001');
        expect(ann.createdAt, now);
      });

      test('applies defaults for missing optional fields', () {
        final ann = Announcement.fromJson({}, id: 'ann2');

        expect(ann.id, 'ann2');
        expect(ann.title, 'Untitled');
        expect(ann.body, '');
        expect(ann.type, AnnouncementType.info);
        expect(ann.priority, AnnouncementPriority.medium);
        expect(ann.programId, isNull);
        expect(ann.createdBy, isNull);
      });

      test('uses json id when no explicit id argument is passed', () {
        final ann = Announcement.fromJson({'id': 'json_ann_id'});
        expect(ann.id, 'json_ann_id');
      });
    });

    // ---------------------------------------------------------------
    // toJson
    // ---------------------------------------------------------------
    group('toJson', () {
      test('serializes fields correctly', () {
        final ann = Announcement(
          id: 'ann1',
          title: 'Welcome Event',
          body: 'Join us live on Zoom',
          type: AnnouncementType.event,
          priority: AnnouncementPriority.low,
          programId: 'p1',
          createdBy: 'admin2',
          createdAt: now,
        );

        final json = ann.toJson();

        expect(json['title'], 'Welcome Event');
        expect(json['body'], 'Join us live on Zoom');
        expect(json['type'], AnnouncementType.event);
        expect(json['priority'], AnnouncementPriority.low);
        expect(json['programId'], 'p1');
        expect(json['createdBy'], 'admin2');
        expect(json['createdAt'], isA<Timestamp>());
        expect(json.containsKey('id'), isFalse);
      });

      test('omits null optional fields in toJson', () {
        final ann = Announcement(
          id: 'ann1',
          title: 'Simple Note',
          body: 'Hello',
          createdAt: now,
        );

        final json = ann.toJson();

        expect(json.containsKey('programId'), isFalse);
        expect(json.containsKey('createdBy'), isFalse);
      });
    });

    // ---------------------------------------------------------------
    // copyWith & Constants
    // ---------------------------------------------------------------
    group('copyWith & Constants', () {
      test('copyWith overrides specified fields correctly', () {
        final ann = Announcement.fromJson(fullJson(), id: 'orig');
        final copy = ann.copyWith(
          title: 'Updated Title',
          priority: AnnouncementPriority.low,
        );

        expect(copy.id, 'orig');
        expect(copy.title, 'Updated Title');
        expect(copy.priority, AnnouncementPriority.low);
        expect(copy.body, ann.body);
        expect(copy.type, ann.type);
      });

      test('verifies AnnouncementType constants', () {
        expect(AnnouncementType.info, 'info');
        expect(AnnouncementType.reminder, 'reminder');
        expect(AnnouncementType.deadline, 'deadline');
        expect(AnnouncementType.event, 'event');
      });

      test('verifies AnnouncementPriority constants', () {
        expect(AnnouncementPriority.low, 'low');
        expect(AnnouncementPriority.medium, 'medium');
        expect(AnnouncementPriority.high, 'high');
      });
    });
  });
}
