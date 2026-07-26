package com.school.management.notification;

import com.school.management.common.api.ApiResponse;
import com.school.management.common.api.PageResponse;
import com.school.management.common.api.Paging;
import com.school.management.common.audit.Auditable;
import com.school.management.notification.dto.NotificationDtos.NotificationResponse;
import com.school.management.notification.dto.NotificationDtos.SendNotificationRequest;
import com.school.management.notification.dto.NotificationDtos.SendResult;
import com.school.management.security.service.UserDetailsImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "In-app notification inbox and push broadcasts")
public class NotificationController {

    private final PushNotificationService pushNotificationService;

    @GetMapping
    @PreAuthorize("hasAuthority('notification.read')")
    @Operation(summary = "My notifications", description = "Paginated inbox; pass unreadOnly=true to filter")
    public ApiResponse<PageResponse<NotificationResponse>> inbox(
            @AuthenticationPrincipal UserDetailsImpl principal,
            @RequestParam(defaultValue = "false") Boolean unreadOnly,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id,desc") String sort) {
        return ApiResponse.ok(pushNotificationService.inbox(principal.getId(), unreadOnly,
                Paging.of(page, size, sort)));
    }

    @GetMapping("/unread-count")
    @PreAuthorize("hasAuthority('notification.read')")
    @Operation(summary = "Unread notification count", description = "For the app's badge counter")
    public ApiResponse<Long> unreadCount(@AuthenticationPrincipal UserDetailsImpl principal) {
        return ApiResponse.ok(pushNotificationService.unreadCount(principal.getId()));
    }

    @PutMapping("/{id}/read")
    @PreAuthorize("hasAuthority('notification.read')")
    @Operation(summary = "Mark one notification as read")
    public ApiResponse<NotificationResponse> markRead(@AuthenticationPrincipal UserDetailsImpl principal,
                                                      @PathVariable Long id) {
        return ApiResponse.ok(pushNotificationService.markRead(principal.getId(), id));
    }

    @PutMapping("/read-all")
    @PreAuthorize("hasAuthority('notification.read')")
    @Operation(summary = "Mark all my notifications as read")
    public ApiResponse<Integer> markAllRead(@AuthenticationPrincipal UserDetailsImpl principal) {
        return ApiResponse.ok(pushNotificationService.markAllRead(principal.getId()));
    }

    @PostMapping("/send")
    @PreAuthorize("hasAuthority('notification.send')")
    @Auditable(action = "SEND", entity = "NOTIFICATION")
    @Operation(summary = "Send a push notification",
            description = "Broadcast to every active user of a role (e.g. ROLE_STUDENT) or to an explicit list of userIds")
    public ApiResponse<SendResult> send(@Valid @RequestBody SendNotificationRequest request) {
        return ApiResponse.ok(pushNotificationService.send(request));
    }
}
