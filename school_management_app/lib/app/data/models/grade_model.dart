/// A score for one enrollment + subject + term, enriched with subject info.
class GradeModel {
  GradeModel({
    required this.id,
    required this.enrollmentId,
    required this.subjectId,
    required this.score,
    required this.term,
    this.subjectCode,
    this.subjectName,
    this.gradedBy,
  });

  final int id;
  final int enrollmentId;
  final int subjectId;
  final double score;
  final String term;
  final String? subjectCode;
  final String? subjectName;
  final String? gradedBy;

  /// Simple letter grade for display purposes.
  String get letter {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    if (score >= 50) return 'E';
    return 'F';
  }

  factory GradeModel.fromJson(Map<String, dynamic> json) => GradeModel(
        id: (json['id'] as num).toInt(),
        enrollmentId: (json['enrollmentId'] as num?)?.toInt() ?? 0,
        subjectId: (json['subjectId'] as num?)?.toInt() ?? 0,
        score: (json['score'] as num?)?.toDouble() ?? 0,
        term: json['term'] as String? ?? '',
        subjectCode: json['subjectCode'] as String?,
        subjectName: json['subjectName'] as String?,
        gradedBy: json['gradedBy'] as String?,
      );
}
