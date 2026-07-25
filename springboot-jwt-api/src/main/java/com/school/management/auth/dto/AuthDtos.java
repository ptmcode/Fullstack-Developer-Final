package com.school.management.auth.dto;

import com.school.management.user.dto.UserResponse;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public final class AuthDtos {

    private AuthDtos() {
    }

    public record LoginRequest(
            @NotBlank(message = "Username is required") String username,
            @NotBlank(message = "Password is required") String password) {
    }

    public record LoginResponse(String accessToken, String tokenType, String refreshToken, UserResponse user) {
    }

    public record RefreshTokenRequest(
            @NotBlank(message = "Refresh token is required") String refreshToken) {
    }

    public record RefreshTokenResponse(String accessToken, String tokenType, String refreshToken) {
    }

    public record ForgotPasswordRequest(
            @NotBlank(message = "Email is required") @Email(message = "Invalid email") String email) {
    }

    public record ResetPasswordRequest(
            @NotBlank(message = "Reset token is required") String token,
            @NotBlank(message = "New password is required")
            @Size(min = 6, max = 50, message = "Password must be 6-50 characters") String newPassword) {
    }
}
