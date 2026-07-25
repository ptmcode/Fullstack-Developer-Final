import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/grade_model.dart';

class GradeRepository {
  GradeRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<GradeModel> record({
    required int enrollmentId,
    required int subjectId,
    required double score,
    required String term,
  }) async {
    final envelope = await _api.post(ApiConstants.grades, body: {
      'enrollmentId': enrollmentId,
      'subjectId': subjectId,
      'score': score,
      'term': term,
    });
    return GradeModel.fromJson(envelope.dataAsMap);
  }

  Future<GradeModel> update(
    int id, {
    required int enrollmentId,
    required int subjectId,
    required double score,
    required String term,
  }) async {
    final envelope = await _api.put(ApiConstants.gradeById(id), body: {
      'enrollmentId': enrollmentId,
      'subjectId': subjectId,
      'score': score,
      'term': term,
    });
    return GradeModel.fromJson(envelope.dataAsMap);
  }

  Future<String> deleteGrade(int id) async =>
      (await _api.delete(ApiConstants.gradeById(id))).message;
}
