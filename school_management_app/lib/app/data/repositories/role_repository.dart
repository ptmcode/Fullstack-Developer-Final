import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/role_model.dart';

class RoleRepository {
  RoleRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<List<RoleModel>> listRoles() async {
    final envelope = await _api.get(ApiConstants.roles);
    return envelope.dataAsList.map(RoleModel.fromJson).toList();
  }

  Future<List<String>> listPermissions() async {
    final envelope = await _api.get(ApiConstants.permissions);
    return ((envelope.data as List?) ?? const []).map((e) => '$e').toList();
  }

  Future<RoleModel> replacePermissions(int roleId, List<String> permissions) async {
    final envelope = await _api.put(
      ApiConstants.rolePermissions(roleId),
      body: {'permissions': permissions},
    );
    return RoleModel.fromJson(envelope.dataAsMap);
  }
}
