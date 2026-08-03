/// Type-safe representation of a registration document in Firestore
/// `registrations/{regId}`.
///
/// ## Approval Workflow
/// | Status        | Meaning                                      |
/// |---------------|----------------------------------------------|
/// | `PENDING`     | Default — awaiting admin                     |
/// | `APPROVED`    | Admin confirmed — learner is enrolled        |
/// | `REJECTED`    | Admin denied — re-apply after 30 days        |
/// | `CANCELLED`   | Learner withdrew                             |
/// | `registered`  | LEGACY — treated as APPROVED                 |
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationStatus {
  RegistrationStatus._();
  static const String pending = 'PENDING';
  static const String approved = 'APPROVED';
  static const String rejected = 'REJECTED';
  static const String cancelled = 'CANCELLED';

  /// Old data may have this value — treat as approved.
  static const String registeredLegacy = 'registered';
}

class Registration {
  Registration({
    required this.id,
    required this.programId,
    required this.userId,
    required this.userEmail,
    required this.userName,
    this.status = RegistrationStatus.pending,
    required this.registeredAt,
    this.rejectedAt,
    this.programTitle,
    this.programInstructor,
  });

  final String id;
  final String programId;
  final String userId;
  final String userEmail;
  final String userName;
  final String status;
  final DateTime registeredAt;
  final DateTime? rejectedAt;

  final String? programTitle;
  final String? programInstructor;

  /// True when the learner can access program content.
  bool get isEnrolled => _normalisedStatus == RegistrationStatus.approved;

  /// True when admin approved (or legacy "registered").
  bool get isApproved => _normalisedStatus == RegistrationStatus.approved;

  /// True when awaiting admin decision.
  bool get isPending => status == RegistrationStatus.pending;

  /// True when rejected.
  bool get isRejected => status == RegistrationStatus.rejected;

  /// True when cancelled.
  bool get isCancelled => status == RegistrationStatus.cancelled;

  /// Whether learner can re-apply after rejection (30-day cooldown).
  bool get canReapply {
    if (!isRejected) return false;
    if (rejectedAt == null) return true; // old data without timestamp
    return DateTime.now().difference(rejectedAt!).inDays >= 30;
  }

  /// Days remaining before re-application allowed.
  int get daysUntilReapply {
    if (rejectedAt == null) return 0;
    final remaining = 30 - DateTime.now().difference(rejectedAt!).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Maps legacy "registered" → "APPROVED" for backward compatibility.
  String get _normalisedStatus {
    if (status == RegistrationStatus.registeredLegacy) {
      return RegistrationStatus.approved;
    }
    return status;
  }

  /// Used by MyRegistrations screen — all non-cancelled.
  bool get isVisible => status != RegistrationStatus.cancelled;

  factory Registration.fromJson(Map<String, dynamic> json, {String? id}) {
    return Registration(
      id: id ?? (json['id'] ?? '').toString(),
      programId: (json['programId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userEmail: (json['userEmail'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      status: (json['status'] ?? RegistrationStatus.pending).toString(),
      registeredAt:
          (json['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rejectedAt: (json['rejectedAt'] as Timestamp?)?.toDate(),
      programTitle: json['programTitle']?.toString(),
      programInstructor: json['programInstructor']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'programId': programId,
    'userId': userId,
    'userEmail': userEmail,
    'userName': userName,
    'status': status,
    'registeredAt': Timestamp.fromDate(registeredAt),
    if (rejectedAt != null) 'rejectedAt': Timestamp.fromDate(rejectedAt!),
    if (programTitle != null) 'programTitle': programTitle,
    if (programInstructor != null) 'programInstructor': programInstructor,
  };

  Registration copyWith({String? status, DateTime? rejectedAt}) {
    return Registration(
      id: id,
      programId: programId,
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      status: status ?? this.status,
      registeredAt: registeredAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      programTitle: programTitle,
      programInstructor: programInstructor,
    );
  }
}
