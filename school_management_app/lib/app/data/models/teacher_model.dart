class TeacherModel {
  TeacherModel({
    required this.id,
    required this.teacherCode,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.email,
    this.phone,
    this.specialization,
    this.status,
  });

  final int id;
  final String teacherCode;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? email;
  final String? phone;
  final String? specialization;
  final String? status;

  String get fullName => '$firstName $lastName'.trim();

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
        id: (json['id'] as num).toInt(),
        teacherCode: json['teacherCode'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        gender: json['gender'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        specialization: json['specialization'] as String?,
        status: json['status'] as String?,
      );
}
