/// Type-safe representation of a user document in Firestore `users/{uid}`.
///
/// Every authenticated learner has one of these. Admins are simply users
/// whose [role] has been set to [AppRoles.admin] from the Firebase console.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';

class AppUser {
  AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role = AppRoles.learner,
    this.nationality = '',
    this.photoUrl,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String nationality;
  final String? photoUrl;
  final DateTime createdAt;

  /// Convenience: "Vivek Gupta".
  String get fullName => '$firstName $lastName'.trim();

  /// Convenience: "VG".
  String get initials {
    if (firstName.isEmpty && lastName.isEmpty) return '?';
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
        .toUpperCase();
  }

  bool get isAdmin => role == AppRoles.admin;
  bool get isLearner => role == AppRoles.learner;

  factory AppUser.fromJson(Map<String, dynamic> json, {required String uid}) {
    return AppUser(
      uid: uid,
      email: (json['email'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      role: (json['role'] ?? AppRoles.learner).toString(),
      nationality: (json['nationality'] ?? '').toString(),
      photoUrl: json['photoUrl']?.toString(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
    'nationality': nationality,
    if (photoUrl != null) 'photoUrl': photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  AppUser copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? nationality,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      nationality: nationality ?? this.nationality,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }
}
