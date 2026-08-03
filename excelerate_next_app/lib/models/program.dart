/// Type-safe representation of a program/event document in Firestore
/// `programs/{programId}`.
///
/// A program is a course/workshop that learners can browse and register for.
/// The README calls these "events" and "programs" interchangeably — this
/// model serves both concepts.
import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle status of a program.
class ProgramStatus {
  ProgramStatus._();
  static const String open = 'open'; // accepting registrations
  static const String upcoming = 'upcoming'; // announced, not yet open
  static const String closed = 'closed'; // no longer accepting
}

class Program {
  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.duration,
    required this.level,
    required this.skills,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.capacity = 0,
    this.registeredCount = 0,
    this.status = ProgramStatus.open,
    this.registrationType,
    this.registrationStartDate,
    this.eligibility,
    this.schedule,
    this.imageUrl,
    this.createdBy,
    this.publishAt,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String instructor;
  final String duration;
  final String level;
  final List<String> skills;
  final double rating;
  final int reviewsCount;
  final int capacity;
  final int registeredCount;
  final String status;
  final String? registrationType;
  final DateTime? registrationStartDate;
  final String? eligibility;
  final String? schedule;
  final String? imageUrl;
  final String? createdBy;
  final DateTime? publishAt;
  final DateTime createdAt;

  /// Display string: "4.8 (2.1k reviews)".
  String get ratingDisplay =>
      '${rating.toStringAsFixed(1)} ($reviewsCount reviews)';

  /// "4.8" only — used in cards. Returns "—" when not yet rated.
  String get ratingShort => reviewsCount == 0 ? '—' : rating.toStringAsFixed(1);

  /// Whether seats are still available.
  bool get hasSeats => capacity == 0 || registeredCount < capacity;

  /// Whether registration is currently open.
  /// All published programs with open status and available seats are enrollable.
  bool get isRegistrationOpen => status == ProgramStatus.open && hasSeats;

  /// Whether the program is visible to learners (has reached its publish time).
  /// `null` publishAt means it was published immediately.
  bool get isPublished =>
      publishAt == null || DateTime.now().isAfter(publishAt!);

  factory Program.fromJson(Map<String, dynamic> json, {String? id}) {
    return Program(
      id: id ?? (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Untitled Program').toString(),
      description: (json['description'] ?? 'No description available.')
          .toString(),
      instructor: (json['instructor'] ?? 'Industry Specialist').toString(),
      duration: (json['duration'] ?? 'Self-Paced').toString(),
      level: (json['level'] ?? 'All Levels').toString(),
      skills: (json['skills'] is String)
          ? (json['skills'] as String)
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : List<String>.from((json['skills'] as List?) ?? const []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: (json['reviewsCount'] ?? 0).toInt(),
      capacity: (json['capacity'] ?? 0).toInt(),
      registeredCount: (json['registeredCount'] ?? 0).toInt(),
      status: (json['status'] ?? ProgramStatus.open).toString(),
      registrationType: json['registrationType']?.toString(),
      registrationStartDate: (json['registrationStartDate'] as Timestamp?)
          ?.toDate(),
      eligibility: json['eligibility']?.toString(),
      schedule: json['schedule']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      createdBy: json['createdBy']?.toString(),
      publishAt: (json['publishAt'] as Timestamp?)?.toDate(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'instructor': instructor,
    'duration': duration,
    'level': level,
    'skills': skills,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'capacity': capacity,
    'registeredCount': registeredCount,
    'status': status,
    if (registrationType != null) 'registrationType': registrationType,
    if (registrationStartDate != null)
      'registrationStartDate': Timestamp.fromDate(registrationStartDate!),
    if (eligibility != null) 'eligibility': eligibility,
    if (schedule != null) 'schedule': schedule,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (createdBy != null) 'createdBy': createdBy,
    if (publishAt != null) 'publishAt': Timestamp.fromDate(publishAt!),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Program copyWith({
    String? title,
    String? description,
    String? instructor,
    String? duration,
    String? level,
    List<String>? skills,
    double? rating,
    int? reviewsCount,
    int? capacity,
    int? registeredCount,
    String? status,
    String? registrationType,
    DateTime? registrationStartDate,
    String? eligibility,
    String? schedule,
    String? imageUrl,
    String? createdBy,
    DateTime? publishAt,
  }) {
    return Program(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      skills: skills ?? this.skills,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      status: status ?? this.status,
      registrationType: registrationType ?? this.registrationType,
      registrationStartDate:
          registrationStartDate ?? this.registrationStartDate,
      eligibility: eligibility ?? this.eligibility,
      schedule: schedule ?? this.schedule,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      publishAt: publishAt ?? this.publishAt,
      createdAt: createdAt,
    );
  }

  /// Human-readable description of registration availability.
  String get registrationInfo {
    if (status == ProgramStatus.closed) return 'Registration Closed';
    if (!hasSeats) return 'No seats left';
    return 'Open Now';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Program && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
