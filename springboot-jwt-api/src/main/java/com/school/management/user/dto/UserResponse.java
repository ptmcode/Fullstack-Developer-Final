package com.school.management.user.dto;

import com.school.management.user.Permission;
import com.school.management.user.Role;
import com.school.management.user.User;

import java.time.LocalDateTime;
import java.util.List;

public record UserResponse(Integer id, String username, String email, String firstName, String lastName,
                           String phoneNumber, String status, List<String> roles, List<String> permissions,
                           LocalDateTime createdAt) {

    public static UserResponse from(User user) {
        List<String> roles = user.getRoles().stream().map(Role::getName).sorted().toList();
        List<String> permissions = user.getRoles().stream()
                .flatMap(role -> role.getPermissions().stream())
                .map(Permission::getCode)
                .distinct()
                .sorted()
                .toList();
        return new UserResponse(user.getId(), user.getUsername(), user.getEmail(), user.getFirstName(),
                user.getLastName(), user.getPhoneNumber(), user.getStatus(), roles, permissions,
                user.getCreatedAt());
    }
}
