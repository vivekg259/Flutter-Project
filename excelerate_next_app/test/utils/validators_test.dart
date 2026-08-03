import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_next_app/utils/validators.dart';

void main() {
  group('Validators', () {
    // ---------------------------------------------------------------
    // Validators.email
    // ---------------------------------------------------------------
    group('email', () {
      test('returns error for null or empty string', () {
        expect(Validators.email(null), 'Email is required');
        expect(Validators.email(''), 'Email is required');
        expect(Validators.email('   '), 'Email is required');
      });

      test('returns error for invalid email formats', () {
        expect(Validators.email('plainaddress'), 'Enter a valid email address');
        expect(
          Validators.email('@missinguser.com'),
          'Enter a valid email address',
        );
        expect(Validators.email('user@.com'), 'Enter a valid email address');
        expect(Validators.email('user@domain'), 'Enter a valid email address');
      });

      test('returns null for valid email formats', () {
        expect(Validators.email('user@example.com'), isNull);
        expect(Validators.email('user.name-tag@domain.co.uk'), isNull);
        expect(Validators.email('  user@domain.org  '), isNull); // trimmed
      });
    });

    // ---------------------------------------------------------------
    // Validators.password
    // ---------------------------------------------------------------
    group('password', () {
      test('returns error for null or empty string', () {
        expect(Validators.password(null), 'Password is required');
        expect(Validators.password(''), 'Password is required');
      });

      test('returns error for password under 8 characters', () {
        expect(
          Validators.password('1234567'),
          'Password must be at least 8 characters',
        );
      });

      test('returns null for password with 8 or more characters', () {
        expect(Validators.password('12345678'), isNull);
        expect(Validators.password('supersecretpassword'), isNull);
      });
    });

    // ---------------------------------------------------------------
    // Validators.strongPassword
    // ---------------------------------------------------------------
    group('strongPassword', () {
      test('returns error for null or empty string', () {
        expect(Validators.strongPassword(null), 'Password is required');
        expect(Validators.strongPassword(''), 'Password is required');
      });

      test('returns error for password under 8 characters', () {
        expect(
          Validators.strongPassword('a1b2c3d'),
          'Password must be at least 8 characters',
        );
      });

      test('returns error when missing numbers or letters', () {
        expect(
          Validators.strongPassword('abcdefgh'),
          'Password must contain letters and numbers',
        );
        expect(
          Validators.strongPassword('12345678'),
          'Password must contain letters and numbers',
        );
      });

      test(
        'returns null when containing both letters and numbers (8+ chars)',
        () {
          expect(Validators.strongPassword('Password123'), isNull);
          expect(Validators.strongPassword('p@ssw0rd2026'), isNull);
        },
      );
    });

    // ---------------------------------------------------------------
    // Validators.required
    // ---------------------------------------------------------------
    group('required', () {
      test('returns default error message for null/empty', () {
        expect(Validators.required(null), 'This field is required');
        expect(Validators.required(''), 'This field is required');
        expect(Validators.required('   '), 'This field is required');
      });

      test('returns custom fieldName error message', () {
        expect(
          Validators.required(null, fieldName: 'First Name'),
          'First Name is required',
        );
      });

      test('returns null for non-empty text', () {
        expect(Validators.required('Hello'), isNull);
      });
    });

    // ---------------------------------------------------------------
    // Validators.confirmPassword
    // ---------------------------------------------------------------
    group('confirmPassword', () {
      test('returns error if confirm field is empty', () {
        final validator = Validators.confirmPassword(() => 'secret123');
        expect(validator(null), 'Please confirm your password');
        expect(validator(''), 'Please confirm your password');
      });

      test('returns error if passwords do not match', () {
        final validator = Validators.confirmPassword(() => 'secret123');
        expect(validator('different123'), 'Passwords do not match');
      });

      test('returns null if passwords match', () {
        final validator = Validators.confirmPassword(() => 'secret123');
        expect(validator('secret123'), isNull);
      });
    });

    // ---------------------------------------------------------------
    // Validators.minLength
    // ---------------------------------------------------------------
    group('minLength', () {
      test('returns error if input is null or below min length', () {
        expect(
          Validators.minLength(null, 10, fieldName: 'Review'),
          'Review must be at least 10 characters',
        );
        expect(
          Validators.minLength('Short', 10, fieldName: 'Review'),
          'Review must be at least 10 characters',
        );
      });

      test('returns null if trimmed input length >= min', () {
        expect(
          Validators.minLength('This is long enough', 10, fieldName: 'Review'),
          isNull,
        );
      });
    });
  });
}
