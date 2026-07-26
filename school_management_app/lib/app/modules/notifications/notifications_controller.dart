import 'package:get/get.dart';

import '../../core/base/paged_list_controller.dart';
import '../../core/services/push_notification_service.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/paged_data.dart';
import '../../data/repositories/notification_repository.dart';

/// In-app notification inbox: paginated list, unread filter, read markers
/// and (for admins/teachers) sending announcements.
///
/// The unread counter is kept here because the shell app bar badge and the
/// inbox screen must stay in sync.
class NotificationsController extends PagedListController<NotificationModel> {
  NotificationsController({
    required NotificationRepository notifications,
    required PushNotificationService push,
  })  : _notifications = notifications,
        _push = push;

  final NotificationRepository _notifications;
  final PushNotificationService _push;

  final unreadOnly = false.obs;
  final unreadCount = 0.obs;

  @override
  int get pageSize => 15;

  @override
  void onInit() {
    super.onInit();
    refreshUnreadCount();
    // A push arriving while the app is open should update the badge/list.
    _push.onMessageReceived = () {
      refreshUnreadCount();
      loadPage(0);
    };
  }

  @override
  void onClose() {
    _push.onMessageReceived = null;
    super.onClose();
  }

  @override
  Future<PagedData<NotificationModel>> fetchPage(int page, String search) =>
      _notifications.inbox(
        unreadOnly: unreadOnly.value,
        page: page,
        size: pageSize,
      );

  Future<void> refreshUnreadCount() async {
    try {
      unreadCount.value = await _notifications.unreadCount();
    } catch (_) {
      // A failed badge refresh must never disturb the screen.
    }
  }

  void toggleUnreadOnly(bool value) {
    unreadOnly.value = value;
    loadPage(0);
  }

  /// Marks one notification read and updates the row in place so the list
  /// doesn't jump while the user is reading it.
  Future<void> markRead(NotificationModel notification) async {
    if (notification.read) return;
    final index = items.indexWhere((n) => n.id == notification.id);
    try {
      await _notifications.markRead(notification.id);
      if (unreadOnly.value) {
        items.removeWhere((n) => n.id == notification.id);
        totalElements.value =
            totalElements.value > 0 ? totalElements.value - 1 : 0;
      } else if (index >= 0) {
        items[index] = notification.copyWith(read: true);
      }
      await refreshUnreadCount();
    } catch (_) {
      await reload();
    }
  }

  Future<void> markAllRead() async {
    if (unreadCount.value == 0) return;
    await runAction(
      () => _notifications.markAllRead(),
      successMessage: 'All notifications marked as read',
    );
    await refreshUnreadCount();
  }

  Future<bool> send({
    required String title,
    required String body,
    String? role,
    List<int>? userIds,
  }) async {
    SendResultModel? result;
    final ok = await runAction(
      () async {
        result = await _notifications.send(
          title: title,
          body: body,
          role: role,
          userIds: userIds,
        );
        return result!.summary;
      },
      reloadAfter: false,
    );
    if (ok) {
      await reload();
      await refreshUnreadCount();
    }
    return ok;
  }
}
