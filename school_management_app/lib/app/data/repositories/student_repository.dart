import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/enrollment_model.dart';
import '../models/grade_model.dart';
import '../models/paged_data.dart';
import '../models/student_model.dart';

class StudentRepository {
  StudentRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<PagedData<StudentModel>> list({
    String search = '',
    int page = 0,
    int size = 10,
    String sort = 'id,desc',
  }) async {
    final envelope = await _api.get(ApiConstants.students, query: {
      'search': search,
      'page': '$page',
      'size': '$size',
      'sort': sort,
    });
    return PagedData.fromJson(envelope.dataAsMap, StudentModel.fromJson);
  }

  Future<StudentModel> getById(int id) async {
    final envelope = await _api.get(ApiConstants.studentById(id));
    return StudentModel.fromJson(envelope.dataAsMap);
  }

  Future<StudentModel> create(Map<String, dynamic> body) async {
    final envelope = await _api.post(ApiConstants.students, body: body);
    return StudentModel.fromJson(envelope.dataAsMap);
  }

  Future<StudentModel> update(int id, Map<String, dynamic> body) async {
    final envelope = await _api.put(ApiConstants.studentById(id), body: body);
    return StudentModel.fromJson(envelope.dataAsMap);
  }

  Future<String> deleteStudent(int id) async =>
      (await _api.delete(ApiConstants.studentById(id))).message;

  Future<List<EnrollmentModel>> enrollments(int id) async {
    final envelope = await _api.get(ApiConstants.studentEnrollments(id));
    return envelope.dataAsList.map(EnrollmentModel.fromJson).toList();
  }

  Future<List<GradeModel>> grades(int id) async {
    final envelope = await _api.get(ApiConstants.studentGrades(id));
    return envelope.dataAsList.map(GradeModel.fromJson).toList();
  }
}
