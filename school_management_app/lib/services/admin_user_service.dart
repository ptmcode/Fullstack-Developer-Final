import 'package:simple_state_management_app/models/message_res.dart';
import 'package:simple_state_management_app/services/api_client.dart';

class AdminUserService {
  Future<MessageRes> getUsers({String status = "ALL"}) {
    return ApiClient.postMessage("/api/app/admin/user/list",
        body: {"status": status}, auth: true);
  }

  Future<MessageRes> getUserById(int id) {
    return ApiClient.postMessage("/api/app/admin/user/$id", auth: true);
  }

  Future<MessageRes> createUser(Map<String, dynamic> body) {
    return ApiClient.postMessage("/api/app/admin/user/create",
        body: body, auth: true);
  }

  Future<MessageRes> updateUser(Map<String, dynamic> body) {
    return ApiClient.postMessage("/api/app/admin/user/update",
        body: body, auth: true);
  }

  Future<MessageRes> deleteUser(int id) {
    return ApiClient.postMessage("/api/app/admin/user/delete",
        body: {"id": id}, auth: true);
  }
}
