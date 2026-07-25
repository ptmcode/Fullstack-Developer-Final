package com.school.management.auth;

import com.school.management.auditlog.AuditLogService;
import com.school.management.auth.dto.AuthDtos.ForgotPasswordRequest;
import com.school.management.auth.dto.AuthDtos.LoginRequest;
import com.school.management.auth.dto.AuthDtos.LoginResponse;
import com.school.management.auth.dto.AuthDtos.RefreshTokenRequest;
import com.school.management.auth.dto.AuthDtos.RefreshTokenResponse;
import com.school.management.auth.dto.AuthDtos.ResetPasswordRequest;
import com.school.management.common.constant.Status;
import com.school.management.common.exception.AppException;
import com.school.management.security.jwt.JwtUtils;
import com.school.management.security.service.UserDetailsImpl;
import com.school.management.user.User;
import com.school.management.user.UserRepository;
import com.school.management.user.dto.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String TOKEN_TYPE = "Bearer";

    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final MailService mailService;
    private final AuditLogService auditLogService;

    @Value("${app.jwt.refreshExpirationMs}")
    private long refreshExpirationMs;

    @Value("${app.password-reset.expirationMinutes}")
    private long resetExpirationMinutes;

    @Transactional
    public LoginResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password()));
        SecurityContextHolder.getContext().setAuthentication(authentication);
        UserDetailsImpl principal = (UserDetailsImpl) authentication.getPrincipal();

        String accessToken = jwtUtils.generateTokenFromUsername(principal.getUsername());

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUserId(principal.getId());
        refreshToken.setToken(UUID.randomUUID().toString());
        refreshToken.setExpiryDate(LocalDateTime.now().plusSeconds(refreshExpirationMs / 1000));
        refreshTokenRepository.save(refreshToken);

        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> AppException.unauthorized("User no longer exists"));
        auditLogService.record(principal.getId(), principal.getUsername(), "LOGIN", "AUTH", null, "Login success");
        return new LoginResponse(accessToken, TOKEN_TYPE, refreshToken.getToken(), UserResponse.from(user));
    }

    @Transactional
    public RefreshTokenResponse refresh(RefreshTokenRequest request) {
        RefreshToken refreshToken = refreshTokenRepository.findByToken(request.refreshToken())
                .orElseThrow(() -> AppException.forbidden("Refresh token is invalid. Please sign in again"));

        if (refreshToken.getExpiryDate().isBefore(LocalDateTime.now())) {
            refreshTokenRepository.delete(refreshToken);
            throw AppException.forbidden("Refresh token has expired. Please sign in again");
        }

        User user = userRepository.findById(refreshToken.getUserId())
                .filter(u -> Status.ACTIVE.equals(u.getStatus()))
                .orElseThrow(() -> AppException.forbidden("User is not active. Please contact the administrator"));

        return new RefreshTokenResponse(jwtUtils.generateTokenFromUsername(user.getUsername()),
                TOKEN_TYPE, refreshToken.getToken());
    }

    @Transactional
    public void logout(UserDetailsImpl principal) {
        refreshTokenRepository.deleteByUserId(principal.getId());
        auditLogService.record(principal.getId(), principal.getUsername(), "LOGOUT", "AUTH", null, "Logout");
    }

    /** Always succeeds regardless of whether the email exists, to prevent account enumeration. */
    @Transactional
    public void forgotPassword(ForgotPasswordRequest request) {
        userRepository.findByEmailAndStatus(request.email(), Status.ACTIVE).ifPresent(user -> {
            PasswordResetToken resetToken = new PasswordResetToken();
            resetToken.setUserId(user.getId());
            resetToken.setToken(UUID.randomUUID().toString());
            resetToken.setExpiryDate(LocalDateTime.now().plusMinutes(resetExpirationMinutes));
            resetToken.setUsed(Status.NO);
            passwordResetTokenRepository.save(resetToken);

            mailService.sendPasswordResetToken(user.getEmail(), resetToken.getToken());
            auditLogService.record(user.getId(), user.getUsername(), "FORGOT_PASSWORD", "AUTH", null,
                    "Password reset requested");
        });
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(request.token())
                .orElseThrow(() -> AppException.badRequest("Reset token is invalid"));

        if (Status.YES.equals(resetToken.getUsed()) || resetToken.getExpiryDate().isBefore(LocalDateTime.now())) {
            throw AppException.badRequest("Reset token has expired or was already used");
        }

        User user = userRepository.findById(resetToken.getUserId())
                .orElseThrow(() -> AppException.badRequest("Reset token is invalid"));

        user.setPassword(passwordEncoder.encode(request.newPassword()));
        userRepository.save(user);
        resetToken.setUsed(Status.YES);
        passwordResetTokenRepository.save(resetToken);
        refreshTokenRepository.deleteByUserId(user.getId());

        auditLogService.record(user.getId(), user.getUsername(), "RESET_PASSWORD", "AUTH", null,
                "Password reset completed");
    }
}
