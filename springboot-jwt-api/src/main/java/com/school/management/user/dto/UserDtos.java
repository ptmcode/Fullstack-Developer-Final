package com.school.management.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.List;

public final class UserDtos {

    private UserDtos() {
    }

    /** Used for both create and update; password is required on create only. */
    public record UserRequest(
            @NotBlank(message = "Username is required")
            @Size(min = 3, max = 50, message = "Username must be 3-50 characters") String username,
            @NotBlank(message = "Email is required") @Email(message = "Invalid email") String email,
            @Size(min = 6, max = 50, message = "Password must be 6-50 characters") String password,
            String firstName,
            String lastName,
            String phoneNumber,
            List<String> roles) {
    }

    public record UpdateRolesRequest(List<String> roles) {
    }

    public record ChangePasswordRequest(
            @NotBlank(message = "Current password is required") String currentPassword,
            @NotBlank(message = "New password is required")
            @Size(min = 6, max = 50, message = "Password must be 6-50 characters") String newPassword) {
    }

    public record RolePermissionsRequest(List<String> permissions) {
    }

    public record RoleResponse(Integer id, String name, String description, List<String> permissions) {
    }
}
