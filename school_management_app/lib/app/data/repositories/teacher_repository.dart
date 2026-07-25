import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/paged_data.dart';
import '../models/teacher_model.dart';

class TeacherRepository {
  TeacherRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<PagedData<TeacherModel>> list({
    String search = '',
    int page = 0,
    int size = 10,
    String sort = 'id,desc',
  }) async {
    final envelope = await _api.get(ApiConstants.teachers, query: {
      'search': search,
      'page': '$page',
      'size': '$size',
      'sort': sort,
    });
    return PagedData.fromJson(envelope.dataAsMap, TeacherModel.fromJson);
  }

  Future<TeacherModel> getById(int id) async {
    final envelope = await _api.get(ApiConstants.teacherById(id));
    return TeacherModel.fromJson(envelope.dataAsMap);
  }

  Future<TeacherModel> create(Map<String, dynamic> body) async {
    final envelope = await _api.post(ApiConstants.teachers, body: body);
    return TeacherModel.fromJson(envelope.dataAsMap);
  }

  Future<TeacherModel> update(int id, Map<String, dynamic> body) async {
    final envelope = await _api.put(ApiConstants.teacherById(id), body: body);
    return TeacherModel.fromJson(envelope.dataAsMap);
  }

  Future<String> deleteTeacher(int id) async =>
      (await _api.delete(ApiConstants.teacherById(id))).message;
}
