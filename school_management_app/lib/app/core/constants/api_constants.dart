import 'package:flutter/foundation.dart';

/// Central place for every endpoint of the School Management System API.
///
/// The backend runs on `http://localhost:30033` — on the Android emulator the
/// host machine is reachable through `10.0.2.2` instead of `localhost`.
class ApiConstants {
  ApiConstants._();

  static String get host {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:30033';
    }
    return 'http://localhost:30033';
  }

  static String get baseUrl => '$host/api/v1';

  // Auth
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  // Users
  static const users = '/users';
  static const me = '/users/me';
  static const myPassword = '/users/me/password';
  static String userById(int id) => '/users/$id';
  static String userRoles(int id) => '/users/$id/roles';

  // Roles & permissions
  static const roles = '/roles';
  static const permissions = '/permissions';
  static String rolePermissions(int id) => '/roles/$id/permissions';

  // Dashboard
  static const dashboardSummary = '/dashboard/summary';

  // Students
  static const students = '/students';
  static String studentById(int id) => '/students/$id';
  static String studentEnrollments(int id) => '/students/$id/enrollments';
  static String studentGrades(int id) => '/students/$id/grades';

  // Teachers
  static const teachers = '/teachers';
  static String teacherById(int id) => '/teachers/$id';

  // Subjects
  static const subjects = '/subjects';
  static String subjectById(int id) => '/subjects/$id';

  // Classes
  static const classes = '/classes';
  static String classById(int id) => '/classes/$id';
  static String classEnrollments(int id) => '/classes/$id/enrollments';

  // Enrollments
  static const enrollments = '/enrollments';
  static String enrollmentById(int id) => '/enrollments/$id';
  static String enrollmentGrades(int id) => '/enrollments/$id/grades';

  // Grades
  static const grades = '/grades';
  static String gradeById(int id) => '/grades/$id';

  // Audit logs
  static const auditLogs = '/audit-logs';
}
