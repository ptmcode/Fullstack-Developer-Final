/// Form field validators shared across every module.
class Validators {
  Validators._();

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value, {bool allowEmpty = false}) {
    if (value == null || value.trim().isEmpty) {
      return allowEmpty ? null : 'Email is required';
    }
    final re = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');
    if (!re.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value, {int min = 6, bool allowEmpty = false}) {
    if (value == null || value.isEmpty) {
      return allowEmpty ? null : 'Password is required';
    }
    if (value.length < min) return 'Password must be at least $min characters';
    return null;
  }

  static String? score(String? value) {
    if (value == null || value.trim().isEmpty) return 'Score is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Score must be a number';
    if (n < 0 || n > 100) return 'Score must be between 0 and 100';
    return null;
  }

  static String? intRange(String? value, {required String field, int? min, int? max, bool allowEmpty = false}) {
    if (value == null || value.trim().isEmpty) {
      return allowEmpty ? null : '$field is required';
    }
    final n = int.tryParse(value.trim());
    if (n == null) return '$field must be a whole number';
    if (min != null && n < min) return '$field must be at least $min';
    if (max != null && n > max) return '$field must be at most $max';
    return null;
  }

  /// Academic year in `YYYY-YYYY` format, e.g. 2025-2026.
  static String? academicYear(String? value) {
    if (value == null || value.trim().isEmpty) return 'Academic year is required';
    if (!RegExp(r'^\d{4}-\d{4}$').hasMatch(value.trim())) {
      return 'Use the format YYYY-YYYY, e.g. 2025-2026';
    }
    return null;
  }
}
