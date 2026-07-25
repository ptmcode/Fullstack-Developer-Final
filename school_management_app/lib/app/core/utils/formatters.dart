import 'package:intl/intl.dart';

/// Date/time formatting helpers used across the UI.
class Formatters {
  Formatters._();

  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, HH:mm');
  static final _isoDate = DateFormat('yyyy-MM-dd');

  static String date(DateTime? value) => value == null ? '—' : _date.format(value);

  static String dateTime(DateTime? value) =>
      value == null ? '—' : _dateTime.format(value);

  static String isoDate(DateTime? value) =>
      value == null ? '' : _isoDate.format(value);

  static DateTime? tryParse(String? value) =>
      value == null || value.isEmpty ? null : DateTime.tryParse(value);

  /// "S1" -> "Semester 1", keeps unknown terms as-is.
  static String term(String value) {
    switch (value.toUpperCase()) {
      case 'S1':
        return 'Semester 1';
      case 'S2':
        return 'Semester 2';
      default:
        return value;
    }
  }

  static String gender(String? value) {
    switch (value?.toUpperCase()) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      default:
        return value ?? '—';
    }
  }

  /// "ROLE_ADMIN" -> "Admin"
  static String roleName(String value) {
    final raw = value.replaceFirst('ROLE_', '').replaceAll('_', ' ').toLowerCase();
    return raw.isEmpty
        ? value
        : raw[0].toUpperCase() + raw.substring(1);
  }
}
