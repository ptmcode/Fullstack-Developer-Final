class StudentModel {
  StudentModel({
    required this.id,
    required this.studentCode,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.dateOfBirth,
    this.email,
    this.phone,
    this.address,
    this.status,
    this.createdAt,
    this.createdBy,
  });

  final int id;
  final String studentCode;
  final String firstName;
  final String lastName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? email;
  final String? phone;
  final String? address;
  final String? status;
  final DateTime? createdAt;
  final String? createdBy;

  String get fullName => '$firstName $lastName'.trim();

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: (json['id'] as num).toInt(),
        studentCode: json['studentCode'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        gender: json['gender'] as String?,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.tryParse(json['dateOfBirth'] as String)
            : null,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        status: json['status'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        createdBy: json['createdBy'] as String?,
      );
}
