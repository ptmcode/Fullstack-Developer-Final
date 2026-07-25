package com.school.management.masterdata.teacher;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface TeacherRepository extends JpaRepository<Teacher, Integer> {

    Optional<Teacher> findByTeacherCode(String teacherCode);

    long countByStatus(String status);

    @Query("""
            SELECT t FROM Teacher t
            WHERE t.status <> 'DEL'
              AND (LOWER(t.teacherCode) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(t.firstName) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(t.lastName) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(COALESCE(t.specialization, '')) LIKE LOWER(CONCAT('%', :q, '%')))
            """)
    Page<Teacher> search(@Param("q") String q, Pageable pageable);
}
