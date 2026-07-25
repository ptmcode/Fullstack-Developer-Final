import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart' hide Response;
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/token_store.dart';
import 'api_exception.dart';

/// Envelope every backend response is wrapped in: `{code, message, data}`.
class ApiEnvelope {
  ApiEnvelope({required this.code, required this.message, this.data});

  final String code;
  final String message;
  final dynamic data;

  Map<String, dynamic> get dataAsMap =>
      (data as Map?)?.cast<String, dynamic>() ?? const {};

  List<Map<String, dynamic>> get dataAsList =>
      (data as List? ?? const []).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
}

/// Thin JWT-aware HTTP client on top of `package:http`.
///
/// Responsibilities:
///  * prefix every path with the API base URL,
///  * attach the `Authorization: Bearer` header,
///  * on 401 transparently refresh the access token once (single-flight,
///    concurrent requests share the same refresh future) and retry,
///  * translate error payloads into typed [ApiException]s,
///  * notify the app when the session cannot be recovered.
class ApiClient extends GetxService {
  ApiClient({required TokenStore tokens, http.Client? httpClient})
      : _tokens = tokens,
        _http = httpClient ?? http.Client();

  final TokenStore _tokens;
  final http.Client _http;

  /// Set by the session layer; invoked when a refresh attempt fails and the
  /// user has to sign in again.
  void Function()? onSessionExpired;

  Future<String?>? _refreshInFlight;

  static const _timeout = Duration(seconds: 20);

  // --- Public verbs --------------------------------------------------------

  Future<ApiEnvelope> get(String path, {Map<String, String>? query, bool auth = true}) =>
      _request('GET', path, query: query, auth: auth);

  Future<ApiEnvelope> post(String path, {Object? body, bool auth = true}) =>
      _request('POST', path, body: body, auth: auth);

  Future<ApiEnvelope> put(String path, {Object? body, bool auth = true}) =>
      _request('PUT', path, body: body, auth: auth);

  Future<ApiEnvelope> delete(String path, {bool auth = true}) =>
      _request('DELETE', path, auth: auth);

  // --- Core pipeline --------------------------------------------------------

  Future<ApiEnvelope> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    required bool auth,
  }) async {
    http.Response response;
    try {
      response = await _send(method, path, query: query, body: body, auth: auth);
      if (response.statusCode == 401 && auth) {
        final newToken = await _refreshAccessToken();
        if (newToken == null) {
          onSessionExpired?.call();
          throw ApiException.sessionExpired();
        }
        response = await _send(method, path, query: query, body: body, auth: auth);
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException.network();
    }
    return _decode(response);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    required bool auth,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path')
        .replace(queryParameters: query?.isNotEmpty == true ? query : null);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (auth && _tokens.accessToken != null)
        'Authorization': 'Bearer ${_tokens.accessToken}',
    };

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final streamed = await _http.send(request).timeout(_timeout);
    return http.Response.fromStream(streamed);
  }

  /// Exchanges the refresh token for a new access token. Concurrent 401s
  /// share one refresh call; returns `null` when the session is beyond repair.
  Future<String?> _refreshAccessToken() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<String?> _doRefresh() async {
    final refreshToken = _tokens.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await _send(
        'POST',
        ApiConstants.refresh,
        body: {'refreshToken': refreshToken},
        auth: false,
      );
      if (response.statusCode != 200) return null;

      final data = (jsonDecode(response.body)['data'] as Map?)?.cast<String, dynamic>();
      final access = data?['accessToken'] as String?;
      if (access == null) return null;

      await _tokens.saveTokens(
        access: access,
        refresh: data?['refreshToken'] as String?,
      );
      return access;
    } catch (_) {
      return null;
    }
  }

  ApiEnvelope _decode(http.Response response) {
    Map<String, dynamic>? json;
    try {
      json = (jsonDecode(utf8.decode(response.bodyBytes)) as Map).cast<String, dynamic>();
    } catch (_) {
      json = null;
    }

    final success = response.statusCode >= 200 && response.statusCode < 300;
    if (success && json != null) {
      return ApiEnvelope(
        code: json['code'] as String? ?? 'OK',
        message: json['message'] as String? ?? 'Success',
        data: json['data'],
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      code: json?['code'] as String?,
      message: json?['message'] as String? ??
          'Unexpected server error (HTTP ${response.statusCode}).',
      errors: ((json?['errors'] as List?) ?? const []).map((e) => '$e').toList(),
    );
  }

  @override
  void onClose() {
    _http.close();
    super.onClose();
  }
}
