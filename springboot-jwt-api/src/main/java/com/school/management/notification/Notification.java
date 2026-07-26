package com.school.management.notification;

import com.school.management.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/** One notification addressed to one user — also serves as the in-app inbox. */
@Getter
@Setter
@Entity
@Table(name = "notifications")
public class Notification extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(nullable = false, length = 150)
    private String title;

    @Column(nullable = false, length = 500)
    private String body;

    /** GRADE / ENROLLMENT / ANNOUNCEMENT */
    @Column(nullable = false, length = 30)
    private String type;

    @Column(name = "entity_type", length = 50)
    private String entityType;

    @Column(name = "entity_id", length = 50)
    private String entityId;

    @Column(name = "is_read", nullable = false, length = 1)
    private String isRead;

    /** SENT (handed to FCM) / SKIPPED (no devices) / DISABLED (FCM not configured) / FAILED */
    @Column(name = "sent_status", nullable = false, length = 10)
    private String sentStatus;
}
