/// A class (group of students) — named SchoolClass because `Class` collides
/// with the Dart core concept.
class SchoolClassModel {
  SchoolClassModel({
    required this.id,
    required this.classCode,
    required this.name,
    required this.academicYear,
    this.teacherId,
    this.teacherName,
    this.capacity,
    this.status,
  });

  final int id;
  final String classCode;
  final String name;
  final String academicYear;
  final int? teacherId;
  final String? teacherName;
  final int? capacity;
  final String? status;

  factory SchoolClassModel.fromJson(Map<String, dynamic> json) => SchoolClassModel(
        id: (json['id'] as num).toInt(),
        classCode: json['classCode'] as String? ?? '',
        name: json['name'] as String? ?? '',
        academicYear: json['academicYear'] as String? ?? '',
        teacherId: (json['teacherId'] as num?)?.toInt(),
        teacherName: json['teacherName'] as String?,
        capacity: (json['capacity'] as num?)?.toInt(),
        status: json['status'] as String?,
      );
}
