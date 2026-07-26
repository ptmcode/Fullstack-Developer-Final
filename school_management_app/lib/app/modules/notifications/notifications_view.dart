import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/list_page_scaffold.dart';
import '../../data/models/notification_model.dart';
import 'notifications_controller.dart';
import 'send_notification_dialog.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  /// Icon + color per notification type, mirroring the backend's values.
  static const _styles = <String, (IconData, Color)>{
    'GRADE': (Icons.grade_rounded, Color(0xFFF5A54A)),
    'ENROLLMENT': (Icons.how_to_reg_rounded, Color(0xFF57B894)),
    'ANNOUNCEMENT': (Icons.campaign_rounded, Color(0xFF8B7CF6)),
  };

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    return ListPageScaffold<NotificationModel>(
      controller: controller,
      title: 'Notifications',
      subtitle: 'Grades, enrollments and announcements',
      emptyMessage: 'No notifications yet',
      emptyIcon: Icons.notifications_none_rounded,
      headerActions: [
        if (session.hasPermission(AppPermissions.notificationSend))
          FilledButton.icon(
            onPressed: () => SendNotificationDialog.show(controller),
            icon: const Icon(Icons.campaign_outlined),
            label: const Text('Announce'),
          ),
      ],
      filterRow: _FilterRow(controller: controller),
      itemBuilder: (context, item) => _NotificationTile(
        notification: item,
        onTap: () => controller.markRead(item),
        style: _styles[item.type] ??
            (Icons.notifications_rounded, Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: !controller.unreadOnly.value,
            onSelected: (_) => controller.toggleUnreadOnly(false),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(controller.unreadCount.value > 0
                ? 'Unread (${controller.unreadCount.value})'
                : 'Unread'),
            selected: controller.unreadOnly.value,
            onSelected: (_) => controller.toggleUnreadOnly(true),
          ),
          const Spacer(),
          if (controller.unreadCount.value > 0)
            TextButton.icon(
              onPressed: controller.markAllRead,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Mark all read'),
            ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.style,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final (IconData, Color) style;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = !notification.read;
    return Card(
      // Unread rows get a tinted background, like a mail inbox.
      color: unread ? scheme.primary.withValues(alpha: .06) : null,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: style.$2.withValues(alpha: .14),
          child: Icon(style.$1, color: style.$2, size: 21),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (unread)
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(notification.body,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              Formatters.dateTime(notification.createdAt),
              style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
