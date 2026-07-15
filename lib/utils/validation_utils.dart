class ValidationUtils {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validateEmail(String? value) {
    final sanitized = SanitizationUtils.sanitizeEmail(value);
    if (sanitized.isEmpty) return 'Enter an email';
    if (!_emailRegex.hasMatch(sanitized)) return 'Enter a valid email';
    return null;
  }

  /// Password: required only. No uppercase / number / symbol rules.
  /// Minimum length 6 matches Supabase Auth default so sign-up does not fail server-side.
  static String? validatePassword(String? value, {bool forSignUp = false}) {
    if (value == null || value.isEmpty) return 'Enter a password';
    if (forSignUp && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? validateFullName(String? value) {
    final sanitized = SanitizationUtils.sanitizeText(value, maxLength: 50);
    if (sanitized.isEmpty) return 'Enter your full name';
    if (sanitized.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? validateTitle(String? value) {
    final sanitized = SanitizationUtils.sanitizeText(value, maxLength: 100);
    if (sanitized.isEmpty) return 'Enter a title';
    return null;
  }

  static String? validateContent(String? value) {
    final sanitized = SanitizationUtils.sanitizeText(value, maxLength: 5000);
    if (sanitized.isEmpty) return 'Enter note content';
    return null;
  }

  static String? validateReminder(DateTime? reminder) {
    if (reminder == null) return null;
    if (!reminder.isAfter(DateTime.now())) {
      return 'Reminder must be in the future';
    }
    return null;
  }

  static String? validateSpaceName(String? value) {
    final sanitized = SanitizationUtils.sanitizeText(value, maxLength: 40);
    if (sanitized.isEmpty) return 'Enter a space name';
    if (sanitized.length < 2) return 'Space name is too short';
    return null;
  }

  static String? validateSpaceMotto(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final sanitized = SanitizationUtils.sanitizeText(value, maxLength: 80);
    if (sanitized.length > 80) return 'Motto must be 80 characters or less';
    return null;
  }
}

class SanitizationUtils {
  static String sanitizeText(String? value, {int maxLength = 5000}) {
    if (value == null) return '';
    var text = value.trim();
    text = text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }
    return text;
  }

  static String sanitizeEmail(String? value) {
    return sanitizeText(value, maxLength: 254).toLowerCase();
  }
}
