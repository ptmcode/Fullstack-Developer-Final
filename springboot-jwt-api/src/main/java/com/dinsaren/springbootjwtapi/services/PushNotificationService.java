package com.dinsaren.springbootjwtapi.services;

import com.dinsaren.springbootjwtapi.models.notification.PushNotificationRequest;

public interface PushNotificationService {
    void sendPushNotification(PushNotificationRequest req);
}
