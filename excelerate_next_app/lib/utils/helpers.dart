/// Small UI utilities shared across screens.
///
/// These helpers keep screen code free of repeated boilerplate for
/// snackbars, date formatting, and dialog presentation.
import 'package:flutter/material.dart';

/// Shows a short [ScaffoldMessenger] snackbar with a colored background.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

/// Translates a raw [Exception] / Firebase error into a friendly message.
String friendlyError(Object error) {
  final msg = error.toString();
  if (msg.contains('user-not-found') || msg.contains('user_not_found')) {
    return 'No account found with this email. Please sign up first.';
  }
  if (msg.contains('wrong-password') || msg.contains('wrong_password')) {
    return 'Incorrect password. Please try again.';
  }
  if (msg.contains('email-already-in-use') ||
      msg.contains('email_already_in_use')) {
    return 'An account with this email already exists. Try signing in.';
  }
  if (msg.contains('invalid-email') || msg.contains('invalid_email')) {
    return 'The email address is not valid.';
  }
  if (msg.contains('weak-password') || msg.contains('weak_password')) {
    return 'Password is too weak. Use at least 8 characters with letters and numbers.';
  }
  if (msg.contains('network') || msg.contains('network_error')) {
    return 'Network error. Please check your internet connection.';
  }
  if (msg.contains('too-many-requests') || msg.contains('too_many_requests')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (msg.contains('email-not-verified') ||
      msg.contains('Email not verified')) {
    return 'Email not verified. Please check your inbox and verify your email before signing in.';
  }
  if (msg.contains('invalid-credential') ||
      msg.contains('invalid_credential')) {
    return 'Email or password is incorrect.';
  }
  if (msg.contains('already submitted feedback')) {
    return 'You have already submitted feedback & review for this program. '
        'Each program can only be reviewed once.';
  }

  // ---- Cloud Firestore errors ----
  // Without these cases every Firestore failure collapsed into the generic
  // "Something went wrong" message, hiding the real cause from both the
  // learner and the developer.
  if (msg.contains('permission-denied') ||
      msg.contains('permission_denied') ||
      msg.contains('PERMISSION_DENIED')) {
    return 'You do not have permission to perform this action. '
        'Make sure you are enrolled and signed in, then try again.';
  }
  if (msg.contains('unavailable') || msg.contains('UNAVAILABLE')) {
    return 'Cannot reach the server right now. '
        'Please check your internet connection and try again.';
  }
  if (msg.contains('deadline-exceeded') || msg.contains('DEADLINE_EXCEEDED')) {
    return 'The request timed out. Please try again.';
  }
  if (msg.contains('failed-precondition') ||
      msg.contains('FAILED_PRECONDITION') ||
      msg.contains('requires an index')) {
    return 'The server is not configured for this request yet. '
        'Please contact support.';
  }
  if (msg.contains('not-found') || msg.contains('NOT_FOUND')) {
    return 'The requested item no longer exists. Please refresh and try again.';
  }
  if (msg.contains('unauthenticated') || msg.contains('UNAUTHENTICATED')) {
    return 'Your session has expired. Please sign in again.';
  }

  return 'Something went wrong. Please try again.';
}

/// Formats a [DateTime] as "12 Jul 2026".
String formatDate(DateTime? date) {
  if (date == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Formats a [DateTime] as "12 Jul 2026, 3:45 PM".
String formatDateTime(DateTime? date) {
  if (date == null) return '';
  final base = formatDate(date);
  String period = 'AM';
  int hour = date.hour;
  if (hour >= 12) {
    period = 'PM';
    if (hour > 12) hour -= 12;
  }
  if (hour == 0) hour = 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '$base, $hour:$minute $period';
}

/// Returns a short relative-time string like "2h ago", "Just now".
String timeAgo(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(date);
}

/// Builds initials from a name, e.g. "Vivek Gupta" -> "VG".
String initialsOf(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}
