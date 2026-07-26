import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/notification_model.dart';
import '../models/paged_data.dart';

/// Device registration (FCM tokens) and the in-app notification inbox.
class NotificationRepository {
  NotificationRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  // --- Devices --------------------------------------------------------------

  Future<DeviceModel> registerDevice({
    required String token,
    required String deviceType,
    String? deviceName,
  }) async {
    final envelope = await _api.post(ApiConstants.devices, body: {
      'token': token,
      'deviceType': deviceType,
      if (deviceName != null) 'deviceName': deviceName,
    });
    return DeviceModel.fromJson(envelope.dataAsMap);
  }

  Future<List<DeviceModel>> myDevices() async {
    final envelope = await _api.get(ApiConstants.devices);
    return envelope.dataAsList.map(DeviceModel.fromJson).toList();
  }

  Future<String> unregisterDevice(String token) async =>
      (await _api.delete(ApiConstants.devices, query: {'token': token}))
          .message;

  // --- Inbox ------------------------------------------------------------------

  Future<PagedData<NotificationModel>> inbox({
    bool unreadOnly = false,
    int page = 0,
    int size = 15,
    String sort = 'id,desc',
  }) async {
    final envelope = await _api.get(ApiConstants.notifications, query: {
      'unreadOnly': '$unreadOnly',
      'page': '$page',
      'size': '$size',
      'sort': sort,
    });
    return PagedData.fromJson(envelope.dataAsMap, NotificationModel.fromJson);
  }

  Future<int> unreadCount() async {
    final envelope = await _api.get(ApiConstants.unreadCount);
    return (envelope.data as num?)?.toInt() ?? 0;
  }

  Future<String> markRead(int id) async =>
      (await _api.put(ApiConstants.notificationRead(id))).message;

  Future<String> markAllRead() async =>
      (await _api.put(ApiConstants.readAll)).message;

  /// Broadcast to a whole role, or to an explicit list of user ids.
  Future<SendResultModel> send({
    required String title,
    required String body,
    String? role,
    List<int>? userIds,
  }) async {
    final envelope = await _api.post(ApiConstants.sendNotification, body: {
      'title': title,
      'body': body,
      if (role != null) 'role': role,
      if (userIds != null && userIds.isNotEmpty) 'userIds': userIds,
    });
    return SendResultModel.fromJson(envelope.dataAsMap);
  }
}
