import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/enrollment_model.dart';
import '../models/grade_model.dart';
import '../models/paged_data.dart';

class EnrollmentRepository {
  EnrollmentRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<PagedData<EnrollmentModel>> list({
    int page = 0,
    int size = 10,
    String sort = 'id,desc',
    int? studentId,
    int? classId,
  }) async {
    final envelope = await _api.get(ApiConstants.enrollments, query: {
      'page': '$page',
      'size': '$size',
      'sort': sort,
      if (studentId != null) 'studentId': '$studentId',
      if (classId != null) 'classId': '$classId',
    });
    return PagedData.fromJson(envelope.dataAsMap, EnrollmentModel.fromJson);
  }

  Future<EnrollmentModel> enroll({
    required int studentId,
    required int classId,
  }) async {
    final envelope = await _api.post(ApiConstants.enrollments, body: {
      'studentId': studentId,
      'classId': classId,
    });
    return EnrollmentModel.fromJson(envelope.dataAsMap);
  }

  Future<String> remove(int id) async =>
      (await _api.delete(ApiConstants.enrollmentById(id))).message;

  Future<List<GradeModel>> grades(int id) async {
    final envelope = await _api.get(ApiConstants.enrollmentGrades(id));
    return envelope.dataAsList.map(GradeModel.fromJson).toList();
  }
}
