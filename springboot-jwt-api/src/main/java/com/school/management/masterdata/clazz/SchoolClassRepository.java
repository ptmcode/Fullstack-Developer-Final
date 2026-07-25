package com.school.management.masterdata.clazz;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface SchoolClassRepository extends JpaRepository<SchoolClass, Integer> {

    Optional<SchoolClass> findByClassCode(String classCode);

    long countByStatus(String status);

    @Query("""
            SELECT c FROM SchoolClass c
            WHERE c.status <> 'DEL'
              AND (LOWER(c.classCode) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(c.name) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(COALESCE(c.academicYear, '')) LIKE LOWER(CONCAT('%', :q, '%')))
            """)
    Page<SchoolClass> search(@Param("q") String q, Pageable pageable);
}
