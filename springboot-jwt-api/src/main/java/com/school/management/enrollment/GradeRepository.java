package com.school.management.enrollment;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface GradeRepository extends JpaRepository<Grade, Integer> {

    Optional<Grade> findByEnrollmentIdAndSubjectIdAndTerm(Integer enrollmentId, Integer subjectId, String term);

    List<Grade> findByEnrollmentIdAndStatus(Integer enrollmentId, String status);

    List<Grade> findByEnrollmentIdInAndStatus(List<Integer> enrollmentIds, String status);
}
