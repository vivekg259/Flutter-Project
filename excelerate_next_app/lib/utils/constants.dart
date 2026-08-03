/// Centralized brand constants for the Excelerate Next app.
///
/// All colors, spacing, and layout values referenced across the UI
/// should be defined here so that rebranding requires only one edit.
import 'package:flutter/material.dart';

/// Brand color palette (see README branding section).
class AppColors {
  AppColors._(); // prevent instantiation

  /// Deep Blue — AppBar backgrounds, primary text.
  static const Color deepBlue = Color(0xFF003366);

  /// Button Blue — primary call-to-action buttons.
  static const Color buttonBlue = Color(0xFF0056D2);

  /// Vibrant Orange — accent / highlights (e.g., Forgot Password link).
  static const Color orangeAccent = Color(0xFFFF6D00);

  /// Light gray scaffold background.
  static const Color scaffoldBg = Color(0xFFF5F7FA);

  /// Disabled button color (light blue tint).
  static const Color disabledBlue = Color(0xFFB3D9FF);

  /// Soft shadow color used on white cards.
  static const Color cardShadow = Colors.black12;
}

/// Reusable spacing & sizing tokens (logical pixels).
class AppSizes {
  AppSizes._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Standard corner radius for cards and inputs.
  static const double radius = 12;

  /// Larger radius for cards/dialogs.
  static const double radiusLg = 16;

  /// Standard full-width button height.
  static const double buttonHeight = 50;

  /// App logo heights.
  static const double logoSplash = 220;
  static const double logoAppBar = 28;
  static const double logoInline = 50;
}

/// Standard animation durations.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration splash = Duration(seconds: 3);
}

/// User roles stored on the Firestore `users/{uid}` document.
///
/// New signups are always [learner]. The [admin] role must be granted
/// manually from the Firebase console (secure whitelist approach).
class AppRoles {
  AppRoles._();

  static const String learner = 'learner';
  static const String admin = 'admin';
}

/// Firestore collection name constants.
/// Keeping these in one place avoids typos in queries.
class AppCollections {
  AppCollections._();

  static const String users = 'users';
  static const String programs = 'programs';
  static const String registrations = 'registrations';
  static const String announcements = 'announcements';
  static const String feedback = 'feedback';
}
