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

/** An FCM registration token belonging to one user's device. */
@Getter
@Setter
@Entity
@Table(name = "device_tokens")
public class DeviceToken extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(nullable = false, unique = true)
    private String token;

    /** ANDROID / IOS / WEB */
    @Column(name = "device_type", length = 10)
    private String deviceType;

    @Column(name = "device_name", length = 100)
    private String deviceName;

    @Column(nullable = false, length = 3)
    private String status;
}
