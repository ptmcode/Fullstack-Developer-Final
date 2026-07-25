package com.school.management.user;

import com.school.management.common.api.ApiResponse;
import com.school.management.common.api.PageResponse;
import com.school.management.common.api.Paging;
import com.school.management.security.service.UserDetailsImpl;
import com.school.management.user.dto.UserDtos.ChangePasswordRequest;
import com.school.management.user.dto.UserDtos.UpdateRolesRequest;
import com.school.management.user.dto.UserDtos.UserRequest;
import com.school.management.user.dto.UserResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "User Management", description = "User CRUD, role assignment, own profile")
public class UserController {

    private final UserService userService;

    @GetMapping
    @PreAuthorize("hasAuthority('user.read')")
    @Operation(summary = "List users", description = "Paginated, searchable by username/email/name")
    public ApiResponse<PageResponse<UserResponse>> list(
            @RequestParam(defaultValue = "") String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id,desc") String sort) {
        return ApiResponse.ok(userService.list(search, Paging.of(page, size, sort)));
    }

    @GetMapping("/me")
    @Operation(summary = "Current user profile")
    public ApiResponse<UserResponse> me(@AuthenticationPrincipal UserDetailsImpl principal) {
        return ApiResponse.ok(userService.me(principal));
    }

    @PutMapping("/me/password")
    @Operation(summary = "Change own password")
    public ApiResponse<UserResponse> changePassword(@AuthenticationPrincipal UserDetailsImpl principal,
                                                    @Valid @RequestBody ChangePasswordRequest request) {
        return ApiResponse.ok(userService.changePassword(principal, request));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('user.read')")
    @Operation(summary = "Get user by id")
    public ApiResponse<UserResponse> get(@PathVariable Integer id) {
        return ApiResponse.ok(userService.get(id));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('user.create')")
    @Operation(summary = "Create user")
    public ApiResponse<UserResponse> create(@Valid @RequestBody UserRequest request) {
        return ApiResponse.ok(userService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('user.update')")
    @Operation(summary = "Update user")
    public ApiResponse<UserResponse> update(@PathVariable Integer id, @Valid @RequestBody UserRequest request) {
        return ApiResponse.ok(userService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('user.delete')")
    @Operation(summary = "Deactivate user (soft delete)")
    public ApiResponse<UserResponse> delete(@PathVariable Integer id) {
        return ApiResponse.ok(userService.delete(id));
    }

    @PutMapping("/{id}/roles")
    @PreAuthorize("hasAuthority('user.update')")
    @Operation(summary = "Assign roles to user")
    public ApiResponse<UserResponse> updateRoles(@PathVariable Integer id,
                                                 @Valid @RequestBody UpdateRolesRequest request) {
        return ApiResponse.ok(userService.updateRoles(id, request));
    }
}
