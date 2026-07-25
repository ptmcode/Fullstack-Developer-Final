import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/paged_data.dart';
import '../models/subject_model.dart';

class SubjectRepository {
  SubjectRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<PagedData<SubjectModel>> list({
    String search = '',
    int page = 0,
    int size = 10,
    String sort = 'id,desc',
  }) async {
    final envelope = await _api.get(ApiConstants.subjects, query: {
      'search': search,
      'page': '$page',
      'size': '$size',
      'sort': sort,
    });
    return PagedData.fromJson(envelope.dataAsMap, SubjectModel.fromJson);
  }

  Future<SubjectModel> getById(int id) async {
    final envelope = await _api.get(ApiConstants.subjectById(id));
    return SubjectModel.fromJson(envelope.dataAsMap);
  }

  Future<SubjectModel> create(Map<String, dynamic> body) async {
    final envelope = await _api.post(ApiConstants.subjects, body: body);
    return SubjectModel.fromJson(envelope.dataAsMap);
  }

  Future<SubjectModel> update(int id, Map<String, dynamic> body) async {
    final envelope = await _api.put(ApiConstants.subjectById(id), body: body);
    return SubjectModel.fromJson(envelope.dataAsMap);
  }

  Future<String> deleteSubject(int id) async =>
      (await _api.delete(ApiConstants.subjectById(id))).message;
}
