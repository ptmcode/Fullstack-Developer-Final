package com.school.management.notification;

import com.school.management.common.api.ApiResponse;
import com.school.management.notification.dto.NotificationDtos.DeviceResponse;
import com.school.management.notification.dto.NotificationDtos.RegisterDeviceRequest;
import com.school.management.security.service.UserDetailsImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/devices")
@RequiredArgsConstructor
@Tag(name = "Devices", description = "Register mobile devices for Firebase push notifications")
public class DeviceController {

    private final PushNotificationService pushNotificationService;

    @PostMapping
    @Operation(summary = "Register this device for push",
            description = "Stores the FCM registration token of the signed-in user's device. "
                    + "Call after login and whenever Firebase rotates the token.")
    public ApiResponse<DeviceResponse> register(@AuthenticationPrincipal UserDetailsImpl principal,
                                                @Valid @RequestBody RegisterDeviceRequest request) {
        return ApiResponse.ok(DeviceResponse.from(
                pushNotificationService.registerDevice(principal.getId(), request)));
    }

    @GetMapping
    @Operation(summary = "List my registered devices")
    public ApiResponse<List<DeviceResponse>> myDevices(@AuthenticationPrincipal UserDetailsImpl principal) {
        return ApiResponse.ok(pushNotificationService.devicesOf(principal.getId())
                .stream().map(DeviceResponse::from).toList());
    }

    @DeleteMapping
    @Operation(summary = "Unregister a device", description = "Stops push delivery to the given token")
    public ApiResponse<Void> unregister(@AuthenticationPrincipal UserDetailsImpl principal,
                                        @RequestParam String token) {
        pushNotificationService.unregisterDevice(principal.getId(), token);
        return ApiResponse.message("Device unregistered");
    }
}
