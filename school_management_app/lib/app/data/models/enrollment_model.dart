/// Enrollment of a student into a class, enriched by the backend with
/// display-ready student and class descriptors.
class EnrollmentModel {
  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.classId,
    this.studentCode,
    this.studentName,
    this.classCode,
    this.className,
    this.enrolledAt,
    this.status,
  });

  final int id;
  final int studentId;
  final int classId;
  final String? studentCode;
  final String? studentName;
  final String? classCode;
  final String? className;
  final DateTime? enrolledAt;
  final String? status;

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) => EnrollmentModel(
        id: (json['id'] as num).toInt(),
        studentId: (json['studentId'] as num?)?.toInt() ?? 0,
        classId: (json['classId'] as num?)?.toInt() ?? 0,
        studentCode: json['studentCode'] as String?,
        studentName: json['studentName'] as String?,
        classCode: json['classCode'] as String?,
        className: json['className'] as String?,
        enrolledAt: json['enrolledAt'] != null
            ? DateTime.tryParse(json['enrolledAt'] as String)
            : null,
        status: json['status'] as String?,
      );
}
