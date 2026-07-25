class SubjectModel {
  SubjectModel({
    required this.id,
    required this.subjectCode,
    required this.name,
    required this.credit,
    this.description,
    this.status,
  });

  final int id;
  final String subjectCode;
  final String name;
  final int credit;
  final String? description;
  final String? status;

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: (json['id'] as num).toInt(),
        subjectCode: json['subjectCode'] as String? ?? '',
        name: json['name'] as String? ?? '',
        credit: (json['credit'] as num?)?.toInt() ?? 0,
        description: json['description'] as String?,
        status: json['status'] as String?,
      );
}
