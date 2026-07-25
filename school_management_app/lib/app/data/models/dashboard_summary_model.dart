import 'audit_log_model.dart';
import 'enrollment_model.dart';

/// Aggregated counters + recent activity for the dashboard screen.
class DashboardSummaryModel {
  DashboardSummaryModel({
    required this.students,
    required this.teachers,
    required this.subjects,
    required this.classes,
    required this.enrollments,
    required this.users,
    this.recentEnrollments = const [],
    this.recentActivities = const [],
  });

  final int students;
  final int teachers;
  final int subjects;
  final int classes;
  final int enrollments;
  final int users;
  final List<EnrollmentModel> recentEnrollments;
  final List<AuditLogModel> recentActivities;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      DashboardSummaryModel(
        students: (json['students'] as num?)?.toInt() ?? 0,
        teachers: (json['teachers'] as num?)?.toInt() ?? 0,
        subjects: (json['subjects'] as num?)?.toInt() ?? 0,
        classes: (json['classes'] as num?)?.toInt() ?? 0,
        enrollments: (json['enrollments'] as num?)?.toInt() ?? 0,
        users: (json['users'] as num?)?.toInt() ?? 0,
        recentEnrollments: ((json['recentEnrollments'] as List?) ?? const [])
            .cast<Map>()
            .map((e) => EnrollmentModel.fromJson(e.cast<String, dynamic>()))
            .toList(),
        recentActivities: ((json['recentActivities'] as List?) ?? const [])
            .cast<Map>()
            .map((e) => AuditLogModel.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
}
