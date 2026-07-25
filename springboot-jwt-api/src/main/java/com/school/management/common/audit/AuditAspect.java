package com.school.management.common.audit;

import com.school.management.auditlog.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;

@Aspect
@Component
@RequiredArgsConstructor
public class AuditAspect {

    private final AuditLogService auditLogService;

    @AfterReturning(pointcut = "@annotation(auditable)", returning = "result")
    public void afterWrite(JoinPoint joinPoint, Auditable auditable, Object result) {
        auditLogService.record(auditable.action(), auditable.entity(),
                extractId(result), joinPoint.getSignature().toShortString());
    }

    private String extractId(Object result) {
        if (result == null) {
            return null;
        }
        for (String accessor : new String[]{"getId", "id"}) {
            try {
                Object id = result.getClass().getMethod(accessor).invoke(result);
                return id != null ? String.valueOf(id) : null;
            } catch (Exception ignored) {
                // result type has no id accessor — audit without entity id
            }
        }
        return null;
    }
}
