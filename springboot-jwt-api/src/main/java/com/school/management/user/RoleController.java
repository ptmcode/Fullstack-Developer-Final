package com.school.management.user;

import com.school.management.common.api.ApiResponse;
import com.school.management.common.audit.Auditable;
import com.school.management.common.exception.AppException;
import com.school.management.user.dto.UserDtos.RolePermissionsRequest;
import com.school.management.user.dto.UserDtos.RoleResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashSet;
import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Tag(name = "Roles & Permissions", description = "Role catalog and permission assignment")
public class RoleController {

    private final RoleRepository roleRepository;
    private final PermissionRepository permissionRepository;

    @GetMapping("/roles")
    @PreAuthorize("hasAuthority('role.read')")
    @Operation(summary = "List roles with their permissions")
    @Transactional(readOnly = true)
    public ApiResponse<List<RoleResponse>> roles() {
        return ApiResponse.ok(roleRepository.findAll().stream().map(this::toResponse).toList());
    }

    @GetMapping("/permissions")
    @PreAuthorize("hasAuthority('role.read')")
    @Operation(summary = "List all permission codes")
    public ApiResponse<List<String>> permissions() {
        return ApiResponse.ok(permissionRepository.findAll().stream()
                .map(Permission::getCode).sorted().toList());
    }

    @PutMapping("/roles/{id}/permissions")
    @PreAuthorize("hasAuthority('role.update')")
    @Operation(summary = "Replace the permissions of a role")
    @Auditable(action = "UPDATE_PERMISSIONS", entity = "ROLE")
    @Transactional
    public ApiResponse<RoleResponse> updatePermissions(@PathVariable Integer id,
                                                       @RequestBody RolePermissionsRequest request) {
        Role role = roleRepository.findById(id)
                .orElseThrow(() -> AppException.notFound("Role not found"));

        List<String> requested = request.permissions() == null ? List.of() : request.permissions();
        List<Permission> permissions = permissionRepository.findByCodeIn(requested);
        if (permissions.size() != requested.size()) {
            throw AppException.badRequest("Request contains unknown permission codes");
        }
        role.setPermissions(new HashSet<>(permissions));
        return ApiResponse.ok(toResponse(roleRepository.save(role)));
    }

    private RoleResponse toResponse(Role role) {
        return new RoleResponse(role.getId(), role.getName(), role.getDescription(),
                role.getPermissions().stream().map(Permission::getCode).sorted().toList());
    }
}
