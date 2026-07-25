import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:school_management_app/app/core/network/api_client.dart';
import 'package:school_management_app/app/core/network/api_exception.dart';
import 'package:school_management_app/app/core/services/token_store.dart';

/// In-memory token store — no platform channels needed in tests.
class FakeTokenStore implements TokenStore {
  String? access;
  String? refresh;

  FakeTokenStore({this.access, this.refresh});

  @override
  String? get accessToken => access;

  @override
  String? get refreshToken => refresh;

  @override
  bool get hasSession => refresh != null && refresh!.isNotEmpty;

  @override
  Future<void> saveTokens({String? access, String? refresh}) async {
    if (access != null) this.access = access;
    if (refresh != null) this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

http.Response _json(int status, Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), status, headers: {
      'content-type': 'application/json',
    });

void main() {
  group('ApiClient', () {
    test('unwraps the {code, message, data} envelope on success', () async {
      final client = ApiClient(
        tokens: FakeTokenStore(access: 'token'),
        httpClient: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer token');
          return _json(200, {
            'code': 'OK',
            'message': 'Success',
            'data': {'id': 1},
          });
        }),
      );

      final envelope = await client.get('/students/1');
      expect(envelope.code, 'OK');
      expect(envelope.dataAsMap['id'], 1);
    });

    test('throws ApiException with backend code/message/errors on 4xx', () async {
      final client = ApiClient(
        tokens: FakeTokenStore(access: 'token'),
        httpClient: MockClient((request) async => _json(400, {
              'code': 'E400',
              'message': 'Validation failed',
              'errors': ['studentCode must be unique'],
            })),
      );

      try {
        await client.post('/students', body: {});
        fail('should have thrown');
      } on ApiException catch (e) {
        expect(e.statusCode, 400);
        expect(e.code, 'E400');
        expect(e.errors, hasLength(1));
        expect(e.displayMessage, contains('studentCode must be unique'));
      }
    });

    test('refreshes the access token on 401 and retries once', () async {
      final store = FakeTokenStore(access: 'expired', refresh: 'refresh-1');
      var protectedCalls = 0;
      var refreshCalls = 0;

      final client = ApiClient(
        tokens: store,
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/auth/refresh')) {
            refreshCalls++;
            expect(jsonDecode(request.body)['refreshToken'], 'refresh-1');
            return _json(200, {
              'code': 'OK',
              'message': 'Success',
              'data': {'accessToken': 'fresh', 'tokenType': 'Bearer'},
            });
          }
          protectedCalls++;
          if (request.headers['Authorization'] == 'Bearer fresh') {
            return _json(200,
                {'code': 'OK', 'message': 'Success', 'data': {'ok': true}});
          }
          return _json(401, {'code': 'E401', 'message': 'Expired'});
        }),
      );

      final envelope = await client.get('/dashboard/summary');
      expect(envelope.dataAsMap['ok'], true);
      expect(refreshCalls, 1);
      expect(protectedCalls, 2); // original + retry
      expect(store.access, 'fresh');
    });

    test('signals session expiry when the refresh token is rejected', () async {
      var expired = false;
      final client = ApiClient(
        tokens: FakeTokenStore(access: 'expired', refresh: 'dead'),
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/auth/refresh')) {
            return _json(401, {'code': 'E401', 'message': 'Invalid token'});
          }
          return _json(401, {'code': 'E401', 'message': 'Expired'});
        }),
      )..onSessionExpired = () => expired = true;

      await expectLater(
        client.get('/students'),
        throwsA(isA<ApiException>()
            .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)),
      );
      expect(expired, isTrue);
    });

    test('does not attempt refresh for unauthenticated calls', () async {
      var refreshCalls = 0;
      final client = ApiClient(
        tokens: FakeTokenStore(),
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/auth/refresh')) {
            refreshCalls++;
            return _json(401, {'code': 'E401', 'message': 'nope'});
          }
          return _json(401, {'code': 'E401', 'message': 'Bad credentials'});
        }),
      );

      await expectLater(
        client.post('/auth/login',
            body: {'username': 'x', 'password': 'y'}, auth: false),
        throwsA(isA<ApiException>()),
      );
      expect(refreshCalls, 0);
    });

    test('maps transport failures to a friendly network error', () async {
      final client = ApiClient(
        tokens: FakeTokenStore(access: 't'),
        httpClient: MockClient((request) async {
          throw http.ClientException('connection refused');
        }),
      );

      await expectLater(
        client.get('/students'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', isNull)),
      );
    });
  });
}
