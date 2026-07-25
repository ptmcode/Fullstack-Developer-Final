import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// Firebase Cloud Messaging integration.
///
/// * asks for notification permission,
/// * exposes the device FCM token (Profile screen shows it with a copy
///   button so a test push can be sent from the Firebase console),
/// * subscribes to the `announcements` topic,
/// * shows a real system notification banner even while the app is open —
///   on Android through a high-importance local-notification channel, on
///   iOS through FCM's native foreground presentation options.
///
/// Note: on the iOS **simulator** there is no APNs, so no token is issued —
/// test push on an Android emulator (with Play services) or a real device.
class PushNotificationService extends GetxService {
  final fcmToken = RxnString();
  final permissionGranted = false.obs;
  final lastMessage = RxnString();

  /// Human-readable reason when push is unavailable on this device.
  final unavailableReason = RxnString();

  static const topic = 'announcements';

  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'announcements_channel',
    'Announcements',
    description: 'School announcements and alerts',
    importance: Importance.high,
  );

  Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission();
      permissionGranted.value =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!kIsWeb && Platform.isIOS) {
        // iOS shows the system banner itself in foreground with these options.
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        // Without an APNs token (e.g. simulator, missing push entitlement)
        // getToken would throw — bail out gracefully instead.
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          unavailableReason.value =
              'No APNs token — push needs a real device with the APNs key '
              'configured in Firebase. (Android emulator works out of the box.)';
          return;
        }
      }

      if (kIsWeb) {
        // Web push needs a VAPID key + service worker; out of scope here.
        unavailableReason.value = 'Push is configured for Android/iOS builds.';
        return;
      }

      if (Platform.isAndroid) {
        // Android renders nothing in foreground on its own — set up a
        // high-importance channel and mirror FCM messages into it.
        await _localNotifications.initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        );
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }

      fcmToken.value = await messaging.getToken();
      messaging.onTokenRefresh.listen((token) => fcmToken.value = token);

      await messaging.subscribeToTopic(topic);

      // App in foreground: show the notification as a system banner.
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;
        lastMessage.value =
            '${notification.title ?? ''} — ${notification.body ?? ''}';
        if (Platform.isAndroid) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
        // iOS presents the banner natively (presentation options above).
      });

      // App opened by tapping a notification (background → foreground).
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        lastMessage.value = message.notification?.title ?? 'Notification';
      });
    } catch (e) {
      unavailableReason.value = 'Push setup failed: $e';
      debugPrint('PushNotificationService: $e');
    }
  }
}
