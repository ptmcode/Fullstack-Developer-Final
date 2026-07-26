package com.school.management.notification;

import com.school.management.common.api.PageResponse;
import com.school.management.common.constant.Status;
import com.school.management.common.exception.AppException;
import com.school.management.notification.dto.NotificationDtos.NotificationResponse;
import com.school.management.notification.dto.NotificationDtos.RegisterDeviceRequest;
import com.school.management.notification.dto.NotificationDtos.SendNotificationRequest;
import com.school.management.notification.dto.NotificationDtos.SendResult;
import com.school.management.user.User;
import com.school.management.user.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class PushNotificationService {

    public static final String TYPE_GRADE = "GRADE";
    public static final String TYPE_ENROLLMENT = "ENROLLMENT";
    public static final String TYPE_ANNOUNCEMENT = "ANNOUNCEMENT";

    private static final String SENT = "SENT";
    private static final String SKIPPED = "SKIPPED";
    private static final String DISABLED = "DISABLED";

    private final DeviceTokenRepository deviceTokenRepository;
    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final FirebaseMessagingClient firebaseClient;

    // ---------------------------------------------------------------- devices

    /** Registers (or re-assigns) an FCM device token for the current user. */
    @Transactional
    public DeviceToken registerDevice(Integer userId, RegisterDeviceRequest request) {
        DeviceToken device = deviceTokenRepository.findByToken(request.token()).orElseGet(DeviceToken::new);
        device.setUserId(userId);
        device.setToken(request.token());
        device.setDeviceType(request.deviceType());
        device.setDeviceName(request.deviceName());
        device.setStatus(Status.ACTIVE);
        return deviceTokenRepository.save(device);
    }

    @Transactional
    public void unregisterDevice(Integer userId, String token) {
        DeviceToken device = deviceTokenRepository.findByToken(token)
                .filter(d -> d.getUserId().equals(userId))
                .orElseThrow(() -> AppException.notFound("Device token not registered for this user"));
        device.setStatus(Status.DELETED);
        deviceTokenRepository.save(device);
    }

    /** Called on logout so a signed-out device stops receiving pushes. */
    @Transactional
    public void unregisterAllDevices(Integer userId) {
        List<DeviceToken> devices = deviceTokenRepository.findByUserIdAndStatus(userId, Status.ACTIVE);
        devices.forEach(d -> d.setStatus(Status.DELETED));
        deviceTokenRepository.saveAll(devices);
    }

    @Transactional(readOnly = true)
    public List<DeviceToken> devicesOf(Integer userId) {
        return deviceTokenRepository.findByUserIdAndStatus(userId, Status.ACTIVE);
    }

    // ---------------------------------------------------------------- sending

    /**
     * Stores a notification for one user and pushes it to their devices.
     *
     * <p>Runs in its own transaction and never throws: a failed notification must not roll back
     * the business operation that triggered it.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void notifyUser(Integer userId, String title, String body, String type,
                           String entityType, String entityId) {
        if (userId == null) {
            return;
        }
        try {
            deliver(List.of(userId), title, body, type, entityType, entityId);
        } catch (Exception e) {
            log.warn("Failed to send '{}' notification to user {}: {}", type, userId, e.getMessage());
        }
    }

    /** Admin/teacher broadcast to a role or an explicit set of users. */
    @Transactional
    public SendResult send(SendNotificationRequest request) {
        List<Integer> userIds;
        if (StringUtils.hasText(request.role())) {
            userIds = userRepository.findActiveByRoleName(request.role().trim()).stream()
                    .map(User::getId).toList();
            if (userIds.isEmpty()) {
                throw AppException.badRequest("No active users found for role " + request.role());
            }
        } else if (request.userIds() != null && !request.userIds().isEmpty()) {
            userIds = request.userIds();
        } else {
            throw AppException.badRequest("Provide either a role or a list of userIds");
        }
        int devices = deliver(userIds, request.title(), request.body(), TYPE_ANNOUNCEMENT, null, null);
        return new SendResult(userIds.size(), devices, firebaseClient.isEnabled());
    }

    /** Persists one notification per recipient, then pushes to all their devices in one call. */
    private int deliver(List<Integer> userIds, String title, String body, String type,
                        String entityType, String entityId) {
        List<DeviceToken> devices = deviceTokenRepository.findByUserIdInAndStatus(userIds, Status.ACTIVE);
        List<String> tokens = devices.stream().map(DeviceToken::getToken).toList();

        String sentStatus = tokens.isEmpty() ? SKIPPED : (firebaseClient.isEnabled() ? SENT : DISABLED);
        for (Integer userId : userIds) {
            Notification notification = new Notification();
            notification.setUserId(userId);
            notification.setTitle(title);
            notification.setBody(body);
            notification.setType(type);
            notification.setEntityType(entityType);
            notification.setEntityId(entityId);
            notification.setIsRead(Status.NO);
            notification.setSentStatus(sentStatus);
            notificationRepository.save(notification);
        }

        if (tokens.isEmpty()) {
            log.debug("No active devices for user(s) {} — notification stored only", userIds);
            return 0;
        }

        Map<String, String> data = new HashMap<>();
        data.put("type", type);
        if (entityType != null) {
            data.put("entityType", entityType);
        }
        if (entityId != null) {
            data.put("entityId", entityId);
        }

        List<String> invalid = firebaseClient.send(tokens, title, body, data);
        deactivate(invalid);
        return tokens.size() - invalid.size();
    }

    /** Removes tokens FCM reported as uninstalled/invalid so they are not retried. */
    private void deactivate(List<String> tokens) {
        if (tokens.isEmpty()) {
            return;
        }
        List<DeviceToken> stale = deviceTokenRepository.findByTokenIn(tokens);
        stale.forEach(d -> d.setStatus(Status.DELETED));
        deviceTokenRepository.saveAll(stale);
        log.info("Deactivated {} invalid device token(s)", stale.size());
    }

    // ---------------------------------------------------------------- inbox

    @Transactional(readOnly = true)
    public PageResponse<NotificationResponse> inbox(Integer userId, Boolean unreadOnly, Pageable pageable) {
        return PageResponse.from(Boolean.TRUE.equals(unreadOnly)
                        ? notificationRepository.findByUserIdAndIsRead(userId, Status.NO, pageable)
                        : notificationRepository.findByUserId(userId, pageable),
                NotificationResponse::from);
    }

    @Transactional(readOnly = true)
    public long unreadCount(Integer userId) {
        return notificationRepository.countByUserIdAndIsRead(userId, Status.NO);
    }

    @Transactional
    public NotificationResponse markRead(Integer userId, Long id) {
        Notification notification = notificationRepository.findById(id)
                .filter(n -> n.getUserId().equals(userId))
                .orElseThrow(() -> AppException.notFound("Notification not found"));
        notification.setIsRead(Status.YES);
        return NotificationResponse.from(notificationRepository.save(notification));
    }

    @Transactional
    public int markAllRead(Integer userId) {
        return notificationRepository.markAllRead(userId);
    }
}
