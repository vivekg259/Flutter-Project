/// Type-safe representation of a feedback document in Firestore
/// `feedback/{feedbackId}`.
///
/// Submitted by learners after attending an event. Aggregated by the admin
/// feedback dashboard to compute average ratings.
import 'package:cloud_firestore/cloud_firestore.dart';

/// Course pace options presented as tags on the Feedback screen.
class FeedbackPace {
  FeedbackPace._();
  static const String tooSlow = 'too_slow';
  static const String justRight = 'just_right';
  static const String tooFast = 'too_fast';
}

class Feedback {
  Feedback({
    required this.id,
    required this.programId,
    required this.userId,
    required this.contentRating,
    required this.instructorRating,
    required this.pace,
    required this.review,
    this.userName,
    this.userEmail,
    this.programTitle,
    required this.createdAt,
  });

  final String id;
  final String programId;
  final String userId;
  final int contentRating; // 1-5
  final int instructorRating; // 1-5
  final String pace;
  final String review;
  final String? userName;
  final String? userEmail;
  final String? programTitle;
  final DateTime createdAt;

  /// Average of the two learner-provided ratings (content + instructor) / 2.
  /// This computed value drives the program's aggregate rating.
  ///
  /// It is also persisted to Firestore as the denormalized `overallRating`
  /// field, which the security rules require on create (range 1-5) and which
  /// lets the admin dashboard sort/filter server-side. `contentRating` and
  /// `instructorRating` remain the single source of truth — `overallRating`
  /// is always derived from them, never read back independently.
  double get averageRating => (contentRating + instructorRating) / 2;

  factory Feedback.fromJson(Map<String, dynamic> json, {String? id}) {
    return Feedback(
      id: id ?? (json['id'] ?? '').toString(),
      programId: (json['programId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      contentRating: ((json['contentRating'] ?? 0) as num).toInt().clamp(1, 5),
      instructorRating: ((json['instructorRating'] ?? 0) as num).toInt().clamp(
        1,
        5,
      ),
      pace: (json['pace'] ?? FeedbackPace.justRight).toString(),
      review: (json['review'] ?? '').toString(),
      userName: json['userName']?.toString(),
      userEmail: json['userEmail']?.toString(),
      programTitle: json['programTitle']?.toString(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'programId': programId,
    'userId': userId,
    'contentRating': contentRating,
    'instructorRating': instructorRating,
    // Denormalized mirror of [averageRating]. REQUIRED by firestore.rules —
    // omitting it makes every create fail with permission-denied.
    'overallRating': averageRating,
    'pace': pace,
    'review': review,
    if (userName != null) 'userName': userName,
    if (userEmail != null) 'userEmail': userEmail,
    if (programTitle != null) 'programTitle': programTitle,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Feedback copyWith({
    String? id,
    String? programId,
    String? userId,
    int? contentRating,
    int? instructorRating,
    String? pace,
    String? review,
    String? userName,
    String? userEmail,
    String? programTitle,
    DateTime? createdAt,
  }) => Feedback(
    id: id ?? this.id,
    programId: programId ?? this.programId,
    userId: userId ?? this.userId,
    contentRating: contentRating ?? this.contentRating,
    instructorRating: instructorRating ?? this.instructorRating,
    pace: pace ?? this.pace,
    review: review ?? this.review,
    userName: userName ?? this.userName,
    userEmail: userEmail ?? this.userEmail,
    programTitle: programTitle ?? this.programTitle,
    createdAt: createdAt ?? this.createdAt,
  );
}
