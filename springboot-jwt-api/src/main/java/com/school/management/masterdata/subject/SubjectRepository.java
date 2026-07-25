package com.school.management.masterdata.subject;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface SubjectRepository extends JpaRepository<Subject, Integer> {

    Optional<Subject> findBySubjectCode(String subjectCode);

    long countByStatus(String status);

    @Query("""
            SELECT s FROM Subject s
            WHERE s.status <> 'DEL'
              AND (LOWER(s.subjectCode) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(s.name) LIKE LOWER(CONCAT('%', :q, '%')))
            """)
    Page<Subject> search(@Param("q") String q, Pageable pageable);
}
