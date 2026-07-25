package com.school.management.masterdata.student;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface StudentRepository extends JpaRepository<Student, Integer> {

    Optional<Student> findByStudentCode(String studentCode);

    long countByStatus(String status);

    @Query("""
            SELECT s FROM Student s
            WHERE s.status <> 'DEL'
              AND (LOWER(s.studentCode) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(s.firstName) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(s.lastName) LIKE LOWER(CONCAT('%', :q, '%')))
            """)
    Page<Student> search(@Param("q") String q, Pageable pageable);
}
