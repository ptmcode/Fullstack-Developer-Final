package com.school.management.user;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByUsername(String username);

    Optional<User> findByUsernameAndStatus(String username, String status);

    Optional<User> findByEmailAndStatus(String email, String status);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    long countByStatus(String status);

    @Query("SELECT u FROM User u JOIN u.roles r WHERE r.name = :role AND u.status = 'ACT'")
    List<User> findActiveByRoleName(@Param("role") String role);

    @Query("""
            SELECT u FROM User u
            WHERE u.status <> 'DEL'
              AND (LOWER(u.username) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(u.email) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(COALESCE(u.firstName, '')) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(COALESCE(u.lastName, '')) LIKE LOWER(CONCAT('%', :q, '%')))
            """)
    Page<User> search(@Param("q") String q, Pageable pageable);
}
