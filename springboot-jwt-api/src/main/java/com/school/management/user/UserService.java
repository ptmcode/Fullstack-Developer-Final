package com.school.management.user;

import com.school.management.auth.RefreshTokenRepository;
import com.school.management.common.api.PageResponse;
import com.school.management.common.audit.Auditable;
import com.school.management.common.constant.Status;
import com.school.management.common.exception.AppException;
import com.school.management.security.service.UserDetailsImpl;
import com.school.management.user.dto.UserDtos.ChangePasswordRequest;
import com.school.management.user.dto.UserDtos.UpdateRolesRequest;
import com.school.management.user.dto.UserDtos.UserRequest;
import com.school.management.user.dto.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public PageResponse<UserResponse> list(String search, Pageable pageable) {
        return PageResponse.from(userRepository.search(search == null ? "" : search.trim(), pageable),
                UserResponse::from);
    }

    @Transactional(readOnly = true)
    public UserResponse get(Integer id) {
        return UserResponse.from(findActive(id));
    }

    @Auditable(action = "CREATE", entity = "USER")
    @Transactional
    public UserResponse create(UserRequest request) {
        if (!StringUtils.hasText(request.password())) {
            throw AppException.badRequest("Password is required");
        }
        if (userRepository.existsByUsername(request.username())) {
            throw AppException.conflict("Username already exists");
        }
        if (userRepository.existsByEmail(request.email())) {
            throw AppException.conflict("Email already exists");
        }

        User user = new User();
        user.setUsername(request.username());
        user.setEmail(request.email());
        user.setPassword(passwordEncoder.encode(request.password()));
        applyProfile(user, request);
        user.setStatus(Status.ACTIVE);
        user.setRoles(resolveRoles(request.roles()));
        return UserResponse.from(userRepository.save(user));
    }

    @Auditable(action = "UPDATE", entity = "USER")
    @Transactional
    public UserResponse update(Integer id, UserRequest request) {
        User user = findActive(id);

        userRepository.findByUsername(request.username())
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw AppException.conflict("Username already exists");
                });

        user.setUsername(request.username());
        user.setEmail(request.email());
        applyProfile(user, request);
        if (StringUtils.hasText(request.password())) {
            user.setPassword(passwordEncoder.encode(request.password()));
        }
        if (request.roles() != null) {
            user.setRoles(resolveRoles(request.roles()));
        }
        return UserResponse.from(userRepository.save(user));
    }

    /** Soft delete: the user can no longer log in and disappears from lists. */
    @Auditable(action = "DELETE", entity = "USER")
    @Transactional
    public UserResponse delete(Integer id) {
        User user = findActive(id);
        user.setStatus(Status.DELETED);
        refreshTokenRepository.deleteByUserId(user.getId());
        return UserResponse.from(userRepository.save(user));
    }

    @Auditable(action = "UPDATE_ROLES", entity = "USER")
    @Transactional
    public UserResponse updateRoles(Integer id, UpdateRolesRequest request) {
        User user = findActive(id);
        user.setRoles(resolveRoles(request.roles()));
        return UserResponse.from(userRepository.save(user));
    }

    @Transactional(readOnly = true)
    public UserResponse me(UserDetailsImpl principal) {
        return UserResponse.from(findActive(principal.getId()));
    }

    @Auditable(action = "CHANGE_PASSWORD", entity = "USER")
    @Transactional
    public UserResponse changePassword(UserDetailsImpl principal, ChangePasswordRequest request) {
        User user = findActive(principal.getId());
        if (!passwordEncoder.matches(request.currentPassword(), user.getPassword())) {
            throw AppException.badRequest("Current password is incorrect");
        }
        user.setPassword(passwordEncoder.encode(request.newPassword()));
        refreshTokenRepository.deleteByUserId(user.getId());
        return UserResponse.from(userRepository.save(user));
    }

    private User findActive(Integer id) {
        return userRepository.findById(id)
                .filter(user -> !Status.DELETED.equals(user.getStatus()))
                .orElseThrow(() -> AppException.notFound("User not found"));
    }

    private void applyProfile(User user, UserRequest request) {
        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setPhoneNumber(request.phoneNumber());
    }

    private Set<Role> resolveRoles(List<String> roleNames) {
        Set<Role> roles = new HashSet<>();
        if (roleNames != null) {
            for (String name : roleNames) {
                roles.add(roleRepository.findByName(name)
                        .orElseThrow(() -> AppException.badRequest("Unknown role: " + name)));
            }
        }
        return roles;
    }
}
