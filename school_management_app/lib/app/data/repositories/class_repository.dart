import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/enrollment_model.dart';
import '../models/paged_data.dart';
import '../models/school_class_model.dart';

class ClassRepository {
  ClassRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<PagedData<SchoolClassModel>> list({
    String search = '',
    int page = 0,
    int size = 10,
    String sort = 'id,desc',
  }) async {
    final envelope = await _api.get(ApiConstants.classes, query: {
      'search': search,
      'page': '$page',
      'size': '$size',
      'sort': sort,
    });
    return PagedData.fromJson(envelope.dataAsMap, SchoolClassModel.fromJson);
  }

  Future<SchoolClassModel> getById(int id) async {
    final envelope = await _api.get(ApiConstants.classById(id));
    return SchoolClassModel.fromJson(envelope.dataAsMap);
  }

  Future<SchoolClassModel> create(Map<String, dynamic> body) async {
    final envelope = await _api.post(ApiConstants.classes, body: body);
    return SchoolClassModel.fromJson(envelope.dataAsMap);
  }

  Future<SchoolClassModel> update(int id, Map<String, dynamic> body) async {
    final envelope = await _api.put(ApiConstants.classById(id), body: body);
    return SchoolClassModel.fromJson(envelope.dataAsMap);
  }

  Future<String> deleteClass(int id) async =>
      (await _api.delete(ApiConstants.classById(id))).message;

  Future<List<EnrollmentModel>> enrollments(int id) async {
    final envelope = await _api.get(ApiConstants.classEnrollments(id));
    return envelope.dataAsList.map(EnrollmentModel.fromJson).toList();
  }
}
