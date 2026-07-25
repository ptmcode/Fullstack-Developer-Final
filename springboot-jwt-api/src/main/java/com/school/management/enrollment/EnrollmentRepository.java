package com.school.management.enrollment;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface EnrollmentRepository extends JpaRepository<Enrollment, Integer> {

    Optional<Enrollment> findByStudentIdAndClassId(Integer studentId, Integer classId);

    long countByClassIdAndStatus(Integer classId, String status);

    long countByStatus(String status);

    List<Enrollment> findByClassIdAndStatus(Integer classId, String status);

    List<Enrollment> findByStudentIdAndStatus(Integer studentId, String status);

    List<Enrollment> findTop5ByStatusOrderByIdDesc(String status);

    @Query("""
            SELECT e FROM Enrollment e
            WHERE e.status <> 'DEL'
              AND (:studentId = 0 OR e.studentId = :studentId)
              AND (:classId = 0 OR e.classId = :classId)
            """)
    Page<Enrollment> search(@Param("studentId") Integer studentId,
                            @Param("classId") Integer classId,
                            Pageable pageable);
}
