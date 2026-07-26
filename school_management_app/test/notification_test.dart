import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:school_management_app/app/core/network/api_client.dart';
import 'package:school_management_app/app/data/models/notification_model.dart';
import 'package:school_management_app/app/data/repositories/notification_repository.dart';

import 'api_client_test.dart' show FakeTokenStore;

http.Response _json(Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), 200,
        headers: {'content-type': 'application/json'});

void main() {
  group('NotificationModel', () {
    test('parses an inbox row', () {
      final n = NotificationModel.fromJson({
        'id': 5,
        'title': 'New grade recorded',
        'body': 'You scored 79.0 in English (term S2)',
        'type': 'GRADE',
        'entityType': 'GRADE',
        'entityId': '55',
        'read': false,
        'sentStatus': 'SENT',
        'createdAt': '2026-07-26T22:40:52.331435',
      });
      expect(n.title, 'New grade recorded');
      expect(n.read, isFalse);
      // Backend sends entityId as a string for entity-linked rows.
      expect(n.entityId, 55);
      expect(n.createdAt, isNotNull);
    });

    test('tolerates nulls and marks read via copyWith', () {
      final n = NotificationModel.fromJson({'id': 1});
      expect(n.type, isNull);
      expect(n.entityId, isNull);
      expect(n.copyWith(read: true).read, isTrue);
    });
  });

  group('SendResultModel.summary', () {
    test('explains dry-run mode', () {
      final r = SendResultModel.fromJson(
          {'recipients': 3, 'devicesReached': 0, 'pushEnabled': false});
      expect(r.summary, contains('dry-run'));
      expect(r.summary, contains('3 recipients'));
    });

    test('reports devices reached', () {
      final r = SendResultModel.fromJson(
          {'recipients': 1, 'devicesReached': 2, 'pushEnabled': true});
      expect(r.summary, 'Sent to 1 recipient on 2 devices');
    });

    test('flags push-enabled sends with no registered devices', () {
      final r = SendResultModel.fromJson(
          {'recipients': 2, 'devicesReached': 0, 'pushEnabled': true});
      expect(r.summary, contains('no registered devices'));
    });
  });

  group('NotificationRepository', () {
    test('registers a device', () async {
      late http.Request captured;
      final repo = NotificationRepository(
        api: ApiClient(
          tokens: FakeTokenStore(access: 't'),
          httpClient: MockClient((request) async {
            captured = request;
            return _json({
              'code': 'OK',
              'message': 'Success',
              'data': {
                'id': 4,
                'token': 'fcm-abc',
                'deviceType': 'ANDROID',
                'deviceName': 'Pixel 7',
                'status': 'ACT',
              },
            });
          }),
        ),
      );

      final device = await repo.registerDevice(
          token: 'fcm-abc', deviceType: 'ANDROID', deviceName: 'Pixel 7');

      expect(captured.method, 'POST');
      expect(captured.url.path, endsWith('/devices'));
      expect(jsonDecode(captured.body)['token'], 'fcm-abc');
      expect(device.deviceType, 'ANDROID');
    });

    test('unregisters a device via query parameter', () async {
      late http.Request captured;
      final repo = NotificationRepository(
        api: ApiClient(
          tokens: FakeTokenStore(access: 't'),
          httpClient: MockClient((request) async {
            captured = request;
            return _json({'code': 'OK', 'message': 'Removed', 'data': null});
          }),
        ),
      );

      await repo.unregisterDevice('fcm-abc');

      expect(captured.method, 'DELETE');
      expect(captured.url.queryParameters['token'], 'fcm-abc');
    });

    test('parses the paginated inbox and unread count', () async {
      final repo = NotificationRepository(
        api: ApiClient(
          tokens: FakeTokenStore(access: 't'),
          httpClient: MockClient((request) async {
            if (request.url.path.endsWith('unread-count')) {
              return _json({'code': 'OK', 'message': 'Success', 'data': 4});
            }
            expect(request.url.queryParameters['unreadOnly'], 'true');
            return _json({
              'code': 'OK',
              'message': 'Success',
              'data': {
                'content': [
                  {'id': 7, 'title': 'Hi', 'body': 'There', 'read': false},
                ],
                'page': 0,
                'size': 15,
                'totalElements': 1,
                'totalPages': 1,
              },
            });
          }),
        ),
      );

      final page = await repo.inbox(unreadOnly: true);
      expect(page.content.single.title, 'Hi');
      expect(await repo.unreadCount(), 4);
    });

    test('sends a role broadcast without userIds', () async {
      late http.Request captured;
      final repo = NotificationRepository(
        api: ApiClient(
          tokens: FakeTokenStore(access: 't'),
          httpClient: MockClient((request) async {
            captured = request;
            return _json({
              'code': 'OK',
              'message': 'Success',
              'data': {
                'recipients': 5,
                'devicesReached': 1,
                'pushEnabled': true,
              },
            });
          }),
        ),
      );

      final result = await repo.send(
          title: 'Holiday', body: 'No classes', role: 'ROLE_STUDENT');

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['role'], 'ROLE_STUDENT');
      expect(body.containsKey('userIds'), isFalse);
      expect(result.recipients, 5);
    });
  });
}
