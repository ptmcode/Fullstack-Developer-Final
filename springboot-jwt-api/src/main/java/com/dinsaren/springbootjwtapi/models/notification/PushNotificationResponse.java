package com.dinsaren.springbootjwtapi.models.notification;

public class PushNotificationResponse {
    private String message_id;

    public String getMessage_id() {
        return message_id;
    }

    public void setMessage_id(String message_id) {
        this.message_id = message_id;
    }

    @Override
    public String toString() {
        return "PushNotificationResponse{" +
                "message_id='" + message_id + '\'' +
                '}';
    }
}
