package com.school.management.auditlog;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    @Query("""
            SELECT a FROM AuditLog a
            WHERE (:username = '' OR LOWER(a.username) LIKE LOWER(CONCAT('%', :username, '%')))
              AND (:action = '' OR a.action = :action)
              AND (:entityType = '' OR a.entityType = :entityType)
              AND a.createdAt BETWEEN :from AND :to
            """)
    Page<AuditLog> search(@Param("username") String username,
                          @Param("action") String action,
                          @Param("entityType") String entityType,
                          @Param("from") LocalDateTime from,
                          @Param("to") LocalDateTime to,
                          Pageable pageable);

    List<AuditLog> findTop5ByOrderByIdDesc();
}
