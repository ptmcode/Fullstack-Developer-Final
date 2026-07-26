package com.school.management.notification;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    Page<Notification> findByUserId(Integer userId, Pageable pageable);

    Page<Notification> findByUserIdAndIsRead(Integer userId, String isRead, Pageable pageable);

    long countByUserIdAndIsRead(Integer userId, String isRead);

    @Modifying
    @Query("UPDATE Notification n SET n.isRead = 'Y' WHERE n.userId = :userId AND n.isRead = 'N'")
    int markAllRead(@Param("userId") Integer userId);
}
