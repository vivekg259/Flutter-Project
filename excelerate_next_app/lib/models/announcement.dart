/// Type-safe representation of an announcement document in Firestore
/// `announcements/{annId}`.
///
/// Announcements are authored by admins and shown on the learner's home
/// dashboard and updates screen.
import 'package:cloud_firestore/cloud_firestore.dart';

/// Announcement category — controls the icon & color on the Updates screen.
class AnnouncementType {
  AnnouncementType._();
  static const String info = 'info';
  static const String reminder = 'reminder';
  static const String deadline = 'deadline';
  static const String event = 'event';
}

/// Visual priority — affects ordering and color intensity.
class AnnouncementPriority {
  AnnouncementPriority._();
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
}

class Announcement {
  Announcement({
    required this.id,
    required this.title,
    required this.body,
    this.type = AnnouncementType.info,
    this.priority = AnnouncementPriority.medium,
    this.programId,
    this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final String priority;
  final String? programId;
  final String? createdBy;
  final DateTime createdAt;

  factory Announcement.fromJson(Map<String, dynamic> json, {String? id}) {
    return Announcement(
      id: id ?? (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Untitled').toString(),
      body: (json['body'] ?? '').toString(),
      type: (json['type'] ?? AnnouncementType.info).toString(),
      priority: (json['priority'] ?? AnnouncementPriority.medium).toString(),
      programId: json['programId']?.toString(),
      createdBy: json['createdBy']?.toString(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'type': type,
    'priority': priority,
    if (programId != null) 'programId': programId,
    if (createdBy != null) 'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Announcement copyWith({
    String? title,
    String? body,
    String? type,
    String? priority,
    String? programId,
  }) {
    return Announcement(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      programId: programId ?? this.programId,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
