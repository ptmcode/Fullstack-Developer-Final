package com.school.management.auditlog;

import com.school.management.common.api.PageResponse;
import com.school.management.security.service.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogRepository auditLogRepository;

    /** Records an audit entry for the currently authenticated user. */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(String action, String entityType, String entityId, String detail) {
        Integer userId = null;
        String username = null;
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof UserDetailsImpl user) {
            userId = user.getId();
            username = user.getUsername();
        } else if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            username = auth.getName();
        }
        record(userId, username, action, entityType, entityId, detail);
    }

    /** Records an audit entry for an explicit user (e.g. during login, before the context is set). */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(Integer userId, String username, String action, String entityType,
                       String entityId, String detail) {
        try {
            AuditLog entry = new AuditLog();
            entry.setUserId(userId);
            entry.setUsername(username);
            entry.setAction(action);
            entry.setEntityType(entityType);
            entry.setEntityId(entityId);
            entry.setDetail(detail);
            entry.setIpAddress(currentIp());
            auditLogRepository.save(entry);
        } catch (Exception e) {
            // auditing must never break the business operation
            log.warn("Failed to write audit log entry: {}", e.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public PageResponse<AuditLog> search(String username, String action, String entityType,
                                         LocalDate from, LocalDate to, Pageable pageable) {
        LocalDateTime fromTs = from != null ? from.atStartOfDay() : LocalDateTime.of(2000, 1, 1, 0, 0);
        LocalDateTime toTs = to != null ? to.plusDays(1).atStartOfDay() : LocalDateTime.now().plusDays(1);
        return PageResponse.from(auditLogRepository.search(
                username == null ? "" : username.trim(),
                action == null ? "" : action.trim(),
                entityType == null ? "" : entityType.trim(),
                fromTs, toTs, pageable));
    }

    private String currentIp() {
        if (RequestContextHolder.getRequestAttributes() instanceof ServletRequestAttributes attrs) {
            return attrs.getRequest().getRemoteAddr();
        }
        return null;
    }
}
