import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:simple_state_management_app/models/message_res.dart';
import 'package:simple_state_management_app/services/session.dart';

class ApiClient {
  static const String baseUrl = "http://localhost:30033";

  static Map<String, String> _headers({bool auth = false}) {
    var headers = {"Content-Type": "application/json"};
    if (auth && Session.accessToken != null) {
      headers["Authorization"] = "Bearer ${Session.accessToken}";
    }
    return headers;
  }

  static Future<MessageRes> getMessage(String path, {bool auth = false}) {
    return _sendMessage(
      auth,
      () => http.get(Uri.parse("$baseUrl$path"), headers: _headers(auth: auth)),
    );
  }

  static Future<MessageRes> postMessage(String path,
      {Object? body, bool auth = false}) {
    return _sendMessage(
      auth,
      () => http.post(
        Uri.parse("$baseUrl$path"),
        headers: _headers(auth: auth),
        body: jsonEncode(body ?? {}),
      ),
    );
  }

  static Future<MessageRes> putMessage(String path,
      {Object? body, bool auth = false}) {
    return _sendMessage(
      auth,
      () => http.put(
        Uri.parse("$baseUrl$path"),
        headers: _headers(auth: auth),
        body: jsonEncode(body ?? {}),
      ),
    );
  }

  static Future<MessageRes> deleteMessage(String path, {bool auth = false}) {
    return _sendMessage(
      auth,
      () =>
          http.delete(Uri.parse("$baseUrl$path"), headers: _headers(auth: auth)),
    );
  }

  static Future<MessageRes> _sendMessage(
      bool auth, Future<http.Response> Function() request) async {
    try {
      var response = await request();
      if (auth && response.statusCode == 401 && Session.refreshToken != null) {
        // Access token expired: refresh once and retry with the new token.
        if (await _refreshToken()) {
          response = await request();
        }
      }
      return MessageRes.fromJson(jsonDecode(response.body));
    } catch (e) {
      return MessageRes(
        code: "ERROR",
        message: "Can not connect to server. Please try again.",
      );
    }
  }

  static Future<bool> _refreshToken() async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/api/oauth/refresh"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": Session.refreshToken}),
      );
      var json = jsonDecode(response.body);
      if (json["accessToken"] != null) {
        Session.accessToken = json["accessToken"];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
