import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/paged_data.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<PagedData<UserModel>> list({
    String search = '',
    int page = 0,
    int size = 10,
    String sort = 'id,desc',
  }) async {
    final envelope = await _api.get(ApiConstants.users, query: {
      'search': search,
      'page': '$page',
      'size': '$size',
      'sort': sort,
    });
    return PagedData.fromJson(envelope.dataAsMap, UserModel.fromJson);
  }

  Future<UserModel> getById(int id) async {
    final envelope = await _api.get(ApiConstants.userById(id));
    return UserModel.fromJson(envelope.dataAsMap);
  }

  Future<UserModel> create(Map<String, dynamic> body) async {
    final envelope = await _api.post(ApiConstants.users, body: body);
    return UserModel.fromJson(envelope.dataAsMap);
  }

  Future<UserModel> update(int id, Map<String, dynamic> body) async {
    final envelope = await _api.put(ApiConstants.userById(id), body: body);
    return UserModel.fromJson(envelope.dataAsMap);
  }

  Future<String> deleteUser(int id) async =>
      (await _api.delete(ApiConstants.userById(id))).message;

  Future<UserModel> assignRoles(int id, List<String> roles) async {
    final envelope =
        await _api.put(ApiConstants.userRoles(id), body: {'roles': roles});
    return UserModel.fromJson(envelope.dataAsMap);
  }

  Future<UserModel> me() async {
    final envelope = await _api.get(ApiConstants.me);
    return UserModel.fromJson(envelope.dataAsMap);
  }

  Future<String> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final envelope = await _api.put(ApiConstants.myPassword, body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    return envelope.message;
  }
}
