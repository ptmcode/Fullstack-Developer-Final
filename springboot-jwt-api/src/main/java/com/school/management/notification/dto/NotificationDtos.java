package com.school.management.notification.dto;

import com.school.management.notification.DeviceToken;
import com.school.management.notification.Notification;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.List;

public final class NotificationDtos {

    private NotificationDtos() {
    }

    public record RegisterDeviceRequest(
            @NotBlank(message = "Device token is required") String token,
            String deviceType,
            String deviceName) {
    }

    public record DeviceResponse(Long id, String token, String deviceType, String deviceName, String status) {

        public static DeviceResponse from(DeviceToken device) {
            return new DeviceResponse(device.getId(), device.getToken(), device.getDeviceType(),
                    device.getDeviceName(), device.getStatus());
        }
    }

    /** Broadcast request: target either a role or an explicit list of user ids. */
    public record SendNotificationRequest(
            @NotBlank(message = "Title is required")
            @Size(max = 150, message = "Title must be at most 150 characters") String title,
            @NotBlank(message = "Body is required")
            @Size(max = 500, message = "Body must be at most 500 characters") String body,
            String role,
            List<Integer> userIds) {
    }

    public record NotificationResponse(Long id, String title, String body, String type, String entityType,
                                       String entityId, boolean read, String sentStatus, LocalDateTime createdAt) {

        public static NotificationResponse from(Notification n) {
            return new NotificationResponse(n.getId(), n.getTitle(), n.getBody(), n.getType(), n.getEntityType(),
                    n.getEntityId(), "Y".equals(n.getIsRead()), n.getSentStatus(), n.getCreatedAt());
        }
    }

    public record SendResult(int recipients, int devicesReached, boolean pushEnabled) {
    }
}
