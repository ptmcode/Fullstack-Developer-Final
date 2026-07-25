import 'package:simple_state_management_app/models/message_res.dart';
import 'package:simple_state_management_app/models/user.dart';
import 'package:simple_state_management_app/services/api_client.dart';

class UserService {
  Future<MessageRes> updateProfile(User user) {
    return ApiClient.postMessage(
      "/api/app/user/update",
      body: {
        "id": user.id,
        "username": user.username,
        "firstName": user.firstName,
        "lastName": user.lastName,
        "email": user.email,
        "phoneNumber": user.phoneNumber,
      },
      auth: true,
    );
  }

  Future<MessageRes> changePassword(
      String oldPassword, String password, String confirmPassword) {
    return ApiClient.postMessage(
      "/api/app/user/change/password",
      body: {
        "oldPassword": oldPassword,
        "password": password,
        "confirmPassword": confirmPassword,
      },
      auth: true,
    );
  }

  Future<MessageRes> getUserById(int id) {
    return ApiClient.postMessage("/api/app/user/$id", auth: true);
  }
}
