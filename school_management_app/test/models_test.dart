import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_app/app/data/models/audit_log_model.dart';
import 'package:school_management_app/app/data/models/dashboard_summary_model.dart';
import 'package:school_management_app/app/data/models/enrollment_model.dart';
import 'package:school_management_app/app/data/models/grade_model.dart';
import 'package:school_management_app/app/data/models/paged_data.dart';
import 'package:school_management_app/app/data/models/role_model.dart';
import 'package:school_management_app/app/data/models/school_class_model.dart';
import 'package:school_management_app/app/data/models/student_model.dart';
import 'package:school_management_app/app/data/models/user_model.dart';

void main() {
  group('PagedData', () {
    test('parses the backend page envelope', () {
      final page = PagedData.fromJson({
        'content': [
          {'id': 1, 'studentCode': 'S001', 'firstName': 'A', 'lastName': 'B'},
          {'id': 2, 'studentCode': 'S002', 'firstName': 'C', 'lastName': 'D'},
        ],
        'page': 0,
        'size': 2,
        'totalElements': 11,
        'totalPages': 6,
      }, StudentModel.fromJson);

      expect(page.content.length, 2);
      expect(page.content.first.studentCode, 'S001');
      expect(page.totalElements, 11);
      expect(page.isFirst, isTrue);
      expect(page.isLast, isFalse);
    });

    test('tolerates a missing content list', () {
      final page = PagedData.fromJson({}, StudentModel.fromJson);
      expect(page.content, isEmpty);
      expect(page.totalPages, 0);
    });
  });

  group('UserModel', () {
    final json = {
      'id': 1,
      'username': 'admin',
      'email': 'admin@school.edu.kh',
      'firstName': 'System',
      'lastName': 'Administrator',
      'status': 'ACT',
      'roles': ['ROLE_ADMIN'],
      'permissions': ['user.read', 'user.create'],
      'createdAt': '2026-07-25T17:06:57.744795',
    };

    test('parses profile with roles and permissions', () {
      final user = UserModel.fromJson(json);
      expect(user.fullName, 'System Administrator');
      expect(user.initials, 'SA');
      expect(user.hasPermission('user.read'), isTrue);
      expect(user.hasPermission('grade.delete'), isFalse);
      expect(user.createdAt, isNotNull);
    });

    test('round-trips through toJson (profile cache)', () {
      final restored = UserModel.fromJson(UserModel.fromJson(json).toJson());
      expect(restored.username, 'admin');
      expect(restored.permissions, contains('user.create'));
    });

    test('falls back to username when names are missing', () {
      final user = UserModel.fromJson({
        'id': 2,
        'username': 'teacher1',
        'email': 't@s.k',
      });
      expect(user.fullName, 'teacher1');
      expect(user.initials, 'T');
    });
  });

  group('AuthSession', () {
    test('parses the login payload', () {
      final session = AuthSession.fromJson({
        'accessToken': 'jwt-token',
        'tokenType': 'Bearer',
        'refreshToken': 'refresh-uuid',
        'user': {'id': 1, 'username': 'admin', 'email': 'a@b.c'},
      });
      expect(session.accessToken, 'jwt-token');
      expect(session.refreshToken, 'refresh-uuid');
      expect(session.user.username, 'admin');
    });
  });

  group('GradeModel', () {
    GradeModel grade(double score) => GradeModel.fromJson({
          'id': 1,
          'enrollmentId': 1,
          'subjectId': 2,
          'score': score,
          'term': 'S1',
        });

    test('letter grade boundaries', () {
      expect(grade(95).letter, 'A');
      expect(grade(85).letter, 'B');
      expect(grade(72.5).letter, 'C');
      expect(grade(60).letter, 'D');
      expect(grade(50).letter, 'E');
      expect(grade(49.9).letter, 'F');
    });
  });

  test('StudentModel parses dates and builds fullName', () {
    final student = StudentModel.fromJson({
      'id': 10,
      'studentCode': 'S010',
      'firstName': 'Theary',
      'lastName': 'Nop',
      'gender': 'F',
      'dateOfBirth': '2008-10-28',
      'status': 'ACT',
    });
    expect(student.fullName, 'Theary Nop');
    expect(student.dateOfBirth!.year, 2008);
  });

  test('SchoolClassModel keeps homeroom teacher enrichment', () {
    final schoolClass = SchoolClassModel.fromJson({
      'id': 3,
      'classCode': 'C11A',
      'name': 'Grade 11A',
      'academicYear': '2025-2026',
      'teacherId': 4,
      'teacherName': 'Channary Lim',
      'capacity': 25,
      'status': 'ACT',
    });
    expect(schoolClass.teacherName, 'Channary Lim');
    expect(schoolClass.capacity, 25);
  });

  test('EnrollmentModel parses enriched student/class descriptors', () {
    final enrollment = EnrollmentModel.fromJson({
      'id': 11,
      'studentId': 11,
      'studentCode': 'S011',
      'studentName': 'Test Student',
      'classId': 1,
      'classCode': 'C10A',
      'className': 'Grade 10A',
      'enrolledAt': '2026-07-25T17:13:54.291556',
      'status': 'ACT',
    });
    expect(enrollment.studentName, 'Test Student');
    expect(enrollment.enrolledAt, isNotNull);
  });

  test('RoleModel parses permissions list', () {
    final role = RoleModel.fromJson({
      'id': 2,
      'name': 'ROLE_TEACHER',
      'description': 'desc',
      'permissions': ['grade.create', 'grade.read'],
    });
    expect(role.permissions, hasLength(2));
  });

  test('AuditLogModel tolerates nulls', () {
    final log = AuditLogModel.fromJson({'id': 108});
    expect(log.username, isNull);
    expect(log.createdAt, isNull);
  });

  test('AuditLogModel parses entityId sent as a string (backend quirk)', () {
    final log = AuditLogModel.fromJson({
      'id': 110,
      'action': 'CREATE',
      'entityType': 'STUDENT',
      'entityId': '15',
    });
    expect(log.entityId, 15);
  });

  test('DashboardSummaryModel parses counters and nested lists', () {
    final summary = DashboardSummaryModel.fromJson({
      'students': 11,
      'teachers': 4,
      'subjects': 6,
      'classes': 3,
      'enrollments': 11,
      'users': 3,
      'recentEnrollments': [
        {'id': 1, 'studentId': 1, 'classId': 1},
      ],
      'recentActivities': [
        {'id': 1, 'action': 'LOGIN'},
      ],
    });
    expect(summary.students, 11);
    expect(summary.recentEnrollments, hasLength(1));
    expect(summary.recentActivities.first.action, 'LOGIN');
  });
}
