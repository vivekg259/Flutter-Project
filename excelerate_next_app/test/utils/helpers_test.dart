import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_next_app/utils/helpers.dart';

void main() {
  group('Helpers', () {
    // ---------------------------------------------------------------
    // friendlyError
    // ---------------------------------------------------------------
    group('friendlyError', () {
      test('maps user-not-found error', () {
        expect(
          friendlyError('user-not-found'),
          'No account found with this email. Please sign up first.',
        );
      });

      test('maps wrong-password error', () {
        expect(
          friendlyError('wrong-password'),
          'Incorrect password. Please try again.',
        );
      });

      test('maps email-already-in-use error', () {
        expect(
          friendlyError('email-already-in-use'),
          'An account with this email already exists. Try signing in.',
        );
      });

      test('maps invalid-email error', () {
        expect(
          friendlyError('invalid-email'),
          'The email address is not valid.',
        );
      });

      test('maps weak-password error', () {
        expect(
          friendlyError('weak-password'),
          'Password is too weak. Use at least 8 characters with letters and numbers.',
        );
      });

      test('maps network errors', () {
        expect(
          friendlyError('network_error'),
          'Network error. Please check your internet connection.',
        );
      });

      test('maps too-many-requests error', () {
        expect(
          friendlyError('too-many-requests'),
          'Too many attempts. Please wait a moment and try again.',
        );
      });

      test('maps email-not-verified error', () {
        expect(
          friendlyError('Email not verified'),
          'Email not verified. Please check your inbox and verify your email before signing in.',
        );
      });

      test('maps invalid-credential error', () {
        expect(
          friendlyError('invalid-credential'),
          'Email or password is incorrect.',
        );
      });

      test('maps duplicate feedback error', () {
        expect(
          friendlyError('already submitted feedback'),
          contains('Each program can only be reviewed once'),
        );
      });

      test('maps Firestore permission-denied error', () {
        expect(
          friendlyError('PERMISSION_DENIED: Missing permissions'),
          contains('You do not have permission'),
        );
      });

      test('maps Firestore unavailable error', () {
        expect(
          friendlyError('UNAVAILABLE'),
          contains('Cannot reach the server right now'),
        );
      });

      test('maps Firestore deadline-exceeded error', () {
        expect(
          friendlyError('DEADLINE_EXCEEDED'),
          contains('The request timed out'),
        );
      });

      test('maps Firestore index requirement error', () {
        expect(
          friendlyError('requires an index'),
          contains('The server is not configured for this request yet'),
        );
      });

      test('maps Firestore NOT_FOUND error', () {
        expect(
          friendlyError('NOT_FOUND'),
          contains('The requested item no longer exists'),
        );
      });

      test('maps Firestore UNAUTHENTICATED error', () {
        expect(
          friendlyError('UNAUTHENTICATED'),
          contains('Your session has expired'),
        );
      });

      test('returns default fallback message for unknown errors', () {
        expect(
          friendlyError('Some unexpected error occurred'),
          'Something went wrong. Please try again.',
        );
      });
    });

    // ---------------------------------------------------------------
    // formatDate
    // ---------------------------------------------------------------
    group('formatDate', () {
      test('returns empty string for null date', () {
        expect(formatDate(null), '');
      });

      test('formats date as "15 Jul 2026"', () {
        final date = DateTime(2026, 7, 15);
        expect(formatDate(date), '15 Jul 2026');
      });

      test('formats all 12 month abbreviations correctly', () {
        for (int month = 1; month <= 12; month++) {
          final date = DateTime(2026, month, 1);
          expect(formatDate(date), contains(2026.toString()));
        }
      });
    });

    // ---------------------------------------------------------------
    // formatDateTime
    // ---------------------------------------------------------------
    group('formatDateTime', () {
      test('returns empty string for null', () {
        expect(formatDateTime(null), '');
      });

      test('formats morning time correctly (AM)', () {
        final dt = DateTime(2026, 7, 15, 9, 5);
        expect(formatDateTime(dt), '15 Jul 2026, 9:05 AM');
      });

      test('formats afternoon time correctly (PM)', () {
        final dt = DateTime(2026, 7, 15, 14, 30);
        expect(formatDateTime(dt), '15 Jul 2026, 2:30 PM');
      });

      test('formats midnight (12:00 AM)', () {
        final dt = DateTime(2026, 7, 15, 0, 0);
        expect(formatDateTime(dt), '15 Jul 2026, 12:00 AM');
      });

      test('formats noon (12:00 PM)', () {
        final dt = DateTime(2026, 7, 15, 12, 0);
        expect(formatDateTime(dt), '15 Jul 2026, 12:00 PM');
      });
    });

    // ---------------------------------------------------------------
    // timeAgo
    // ---------------------------------------------------------------
    group('timeAgo', () {
      test('returns empty string for null', () {
        expect(timeAgo(null), '');
      });

      test('returns "Just now" for less than 1 minute ago', () {
        final dt = DateTime.now().subtract(const Duration(seconds: 30));
        expect(timeAgo(dt), 'Just now');
      });

      test('returns minutes ago format', () {
        final dt = DateTime.now().subtract(const Duration(minutes: 15));
        expect(timeAgo(dt), '15m ago');
      });

      test('returns hours ago format', () {
        final dt = DateTime.now().subtract(const Duration(hours: 4));
        expect(timeAgo(dt), '4h ago');
      });

      test('returns days ago format for under 7 days', () {
        final dt = DateTime.now().subtract(const Duration(days: 3));
        expect(timeAgo(dt), '3d ago');
      });

      test('falls back to formatDate for 7 or more days ago', () {
        final dt = DateTime.now().subtract(const Duration(days: 10));
        expect(timeAgo(dt), formatDate(dt));
      });
    });

    // ---------------------------------------------------------------
    // initialsOf
    // ---------------------------------------------------------------
    group('initialsOf', () {
      test('returns ? for null, empty or whitespace string', () {
        expect(initialsOf(null), '?');
        expect(initialsOf(''), '?');
        expect(initialsOf('   '), '?');
      });

      test('returns two uppercase initials for full name', () {
        expect(initialsOf('Vivek Gupta'), 'VG');
        expect(initialsOf('john doe'), 'JD');
      });

      test('handles single name', () {
        expect(initialsOf('Alice'), 'A');
      });

      test('handles extra spaces between names', () {
        expect(initialsOf('  Mary   Jane  Watson '), 'MJ');
      });
    });
  });
}
