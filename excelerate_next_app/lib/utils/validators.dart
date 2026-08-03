/// Reusable form validators used by the auth screens.
///
/// Each validator returns `null` when the input is valid, or an error
/// string to display under the field. This is the contract expected by
/// Flutter's [FormField.validator].
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  /// Requires a non-empty, well-formed email address.
  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Requires a password of at least 8 characters.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Stronger password policy for signup: letters + numbers, 8+ chars.
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    if (!hasLetter || !hasNumber) {
      return 'Password must contain letters and numbers';
    }
    return null;
  }

  /// Required field — used for names, nationality, etc.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Builds a confirm-password validator that must match [other].
  static String? Function(String?) confirmPassword(String Function() other) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != other()) return 'Passwords do not match';
      return null;
    };
  }

  /// Minimum-length validator for free-text reviews.
  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'This',
  }) {
    if (value == null || value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }
}
