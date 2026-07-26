package com.school.management.notification;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DeviceTokenRepository extends JpaRepository<DeviceToken, Long> {

    Optional<DeviceToken> findByToken(String token);

    List<DeviceToken> findByUserIdAndStatus(Integer userId, String status);

    List<DeviceToken> findByUserIdInAndStatus(List<Integer> userIds, String status);

    List<DeviceToken> findByTokenIn(List<String> tokens);
}
