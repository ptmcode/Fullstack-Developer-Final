package com.school.management.auth;

import com.school.management.auth.dto.AuthDtos.ForgotPasswordRequest;
import com.school.management.auth.dto.AuthDtos.LoginRequest;
import com.school.management.auth.dto.AuthDtos.LoginResponse;
import com.school.management.auth.dto.AuthDtos.RefreshTokenRequest;
import com.school.management.auth.dto.AuthDtos.RefreshTokenResponse;
import com.school.management.auth.dto.AuthDtos.ResetPasswordRequest;
import com.school.management.common.api.ApiResponse;
import com.school.management.security.service.UserDetailsImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Login, logout, token refresh and password reset")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    @SecurityRequirements
    @Operation(summary = "Login", description = "Authenticate with username (or email) and password; returns access + refresh tokens")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok(authService.login(request));
    }

    @PostMapping("/refresh")
    @SecurityRequirements
    @Operation(summary = "Refresh access token", description = "Exchange a valid refresh token for a new access token")
    public ApiResponse<RefreshTokenResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ApiResponse.ok(authService.refresh(request));
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout", description = "Revokes all refresh tokens of the current user")
    public ApiResponse<Void> logout(@AuthenticationPrincipal UserDetailsImpl principal) {
        authService.logout(principal);
        return ApiResponse.message("Logged out");
    }

    @PostMapping("/forgot-password")
    @SecurityRequirements
    @Operation(summary = "Forgot password", description = "Sends a single-use reset token to the registered email")
    public ApiResponse<Void> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.forgotPassword(request);
        return ApiResponse.message("If the email exists, a reset token has been sent");
    }

    @PostMapping("/reset-password")
    @SecurityRequirements
    @Operation(summary = "Reset password", description = "Sets a new password using a valid reset token")
    public ApiResponse<Void> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ApiResponse.message("Password has been reset. Please sign in with the new password");
    }
}
