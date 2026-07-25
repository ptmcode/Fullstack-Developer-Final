import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_app/app/core/services/export_service.dart';
import 'package:school_management_app/app/data/models/enrollment_model.dart';
import 'package:school_management_app/app/data/models/grade_model.dart';
import 'package:school_management_app/app/data/models/student_model.dart';

void main() {
  final students = [
    StudentModel.fromJson({
      'id': 1,
      'studentCode': 'S001',
      'firstName': 'Dara',
      'lastName': 'Kim',
      'gender': 'M',
      'dateOfBirth': '2008-03-15',
      'email': 'dara.kim@student.school.edu.kh',
      'phone': '011000001',
      'address': 'Phnom Penh',
      'status': 'ACT',
    }),
    StudentModel.fromJson({
      'id': 2,
      'studentCode': 'S002',
      'firstName': 'Srey',
      'lastName': 'Neang',
      'gender': 'F',
      'status': 'ACT',
    }),
  ];

  group('ExportService', () {
    test('builds a non-empty students PDF', () async {
      final bytes = await ExportService.buildStudentsPdf(students);
      expect(bytes.length, greaterThan(500));
      // PDF magic bytes: %PDF
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('builds a non-empty students Excel workbook', () {
      final bytes = ExportService.buildStudentsExcel(students);
      expect(bytes.length, greaterThan(500));
      // XLSX is a ZIP container: PK magic bytes.
      expect(bytes[0], 0x50);
      expect(bytes[1], 0x4B);
    });

    test('builds a transcript PDF with enrollments and grades', () async {
      final bytes = await ExportService.buildTranscriptPdf(
        student: students.first,
        enrollments: [
          EnrollmentModel.fromJson({
            'id': 1,
            'studentId': 1,
            'classId': 2,
            'className': 'Grade 10B',
            'classCode': 'C10B',
            'enrolledAt': '2026-07-25T10:00:00',
            'status': 'ACT',
          }),
        ],
        grades: [
          GradeModel.fromJson({
            'id': 1,
            'enrollmentId': 1,
            'subjectId': 1,
            'subjectName': 'Mathematics',
            'subjectCode': 'MATH101',
            'score': 88.5,
            'term': 'S1',
            'gradedBy': 'teacher1',
          }),
        ],
      );
      expect(bytes.length, greaterThan(500));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('transcript PDF works with empty enrollments/grades', () async {
      final bytes = await ExportService.buildTranscriptPdf(
        student: students.last,
        enrollments: const [],
        grades: const [],
      );
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
