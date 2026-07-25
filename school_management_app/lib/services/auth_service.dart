import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:simple_state_management_app/models/message_res.dart';
import 'package:simple_state_management_app/models/register_req.dart';
import 'package:simple_state_management_app/models/user.dart';
import 'package:simple_state_management_app/services/api_client.dart';
import 'package:simple_state_management_app/services/session.dart';

class AuthService {
  static const String deviceId = "device-abc-123";

  Future<MessageRes> login(String phoneNumber, String password) async {
    try {
      var response = await http.post(
        Uri.parse("${ApiClient.baseUrl}/api/oauth/token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phoneNumber": phoneNumber, "password": password}),
      );
      var json = jsonDecode(response.body);
      // Login is not wrapped in MessageRes: tokens come at the top level.
      if (json["accessToken"] != null) {
        Session.accessToken = json["accessToken"];
        Session.refreshToken = json["refreshToken"];
        Session.currentUser = User.fromJson(json["user"]);
        return MessageRes(code: "200", message: "Login successfully!");
      }
      return MessageRes(code: "ERROR", message: json["message"] ?? "Login failed");
    } catch (e) {
      return MessageRes(
        code: "ERROR",
        message: "Can not connect to server. Please try again.",
      );
    }
  }

  Future<MessageRes> register(RegisterReq req) {
    return ApiClient.postMessage("/api/oauth/register", body: req.toJson());
  }

  Future<MessageRes> logout() async {
    var res = await ApiClient.postMessage(
      "/api/oauth/logout",
      body: {"userId": Session.currentUser?.id},
      auth: true,
    );
    Session.clear();
    return res;
  }

  Future<MessageRes> forgotPasswordSendOtp(String phoneNumber) {
    return ApiClient.postMessage(
      "/api/oauth/forgot/password",
      body: {"phoneNumber": phoneNumber, "deviceId": deviceId},
    );
  }

  Future<MessageRes> forgotPasswordVerifyOtp(String phoneNumber, String otp) {
    return ApiClient.postMessage(
      "/api/oauth/forgot/password/verify",
      body: {"phoneNumber": phoneNumber, "deviceId": deviceId, "otp": otp},
    );
  }

  Future<MessageRes> forgotPasswordFinish(
      String phoneNumber, String otp, String password, String confirmPassword) {
    return ApiClient.postMessage(
      "/api/oauth/forgot/password/finish",
      body: {
        "phoneNumber": phoneNumber,
        "otp": otp,
        "oldPassword": "",
        "password": password,
        "confirmPassword": confirmPassword,
      },
    );
  }

  Future<MessageRes> uploadProfileImage(File file) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiClient.baseUrl}/api/oauth/image/upload"),
      );
      request.files.add(await http.MultipartFile.fromPath("File", file.path));
      var response = await http.Response.fromStream(await request.send());
      return MessageRes.fromJson(jsonDecode(response.body));
    } catch (e) {
      return MessageRes(
        code: "ERROR",
        message: "Can not connect to server. Please try again.",
      );
    }
  }
}
