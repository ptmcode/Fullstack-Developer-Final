package com.school.management.enrollment;

import com.school.management.common.audit.Auditable;
import com.school.management.common.constant.Status;
import com.school.management.common.exception.AppException;
import com.school.management.enrollment.dto.EnrollmentDtos.GradeRequest;
import com.school.management.enrollment.dto.EnrollmentDtos.GradeResponse;
import com.school.management.masterdata.subject.Subject;
import com.school.management.masterdata.subject.SubjectRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GradeService {

    private final GradeRepository gradeRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final SubjectRepository subjectRepository;

    @Transactional(readOnly = true)
    public List<GradeResponse> listByEnrollment(Integer enrollmentId) {
        List<Grade> grades = gradeRepository.findByEnrollmentIdAndStatus(enrollmentId, Status.ACTIVE);
        return grades.stream().map(enrich(grades)).toList();
    }

    @Transactional(readOnly = true)
    public List<GradeResponse> listByStudent(Integer studentId) {
        List<Integer> enrollmentIds = enrollmentRepository
                .findByStudentIdAndStatus(studentId, Status.ACTIVE)
                .stream().map(Enrollment::getId).toList();
        if (enrollmentIds.isEmpty()) {
            return List.of();
        }
        List<Grade> grades = gradeRepository.findByEnrollmentIdInAndStatus(enrollmentIds, Status.ACTIVE);
        return grades.stream().map(enrich(grades)).toList();
    }

    @Auditable(action = "CREATE", entity = "GRADE")
    @Transactional
    public GradeResponse record(GradeRequest request) {
        Enrollment enrollment = enrollmentRepository.findById(request.enrollmentId())
                .filter(e -> Status.ACTIVE.equals(e.getStatus()))
                .orElseThrow(() -> AppException.badRequest("Enrollment not found or inactive"));
        subjectRepository.findById(request.subjectId())
                .filter(s -> Status.ACTIVE.equals(s.getStatus()))
                .orElseThrow(() -> AppException.badRequest("Subject not found or inactive"));

        // The DB has UNIQUE(enrollment_id, subject_id, term); a soft-deleted grade is re-activated.
        Grade grade = gradeRepository
                .findByEnrollmentIdAndSubjectIdAndTerm(enrollment.getId(), request.subjectId(), request.term())
                .map(existing -> {
                    if (Status.ACTIVE.equals(existing.getStatus())) {
                        throw AppException.conflict("A grade for this subject and term already exists — update it instead");
                    }
                    existing.setStatus(Status.ACTIVE);
                    return existing;
                })
                .orElseGet(Grade::new);

        grade.setEnrollmentId(enrollment.getId());
        grade.setSubjectId(request.subjectId());
        grade.setStatus(Status.ACTIVE);
        apply(grade, request);
        Grade saved = gradeRepository.save(grade);
        return enrich(List.of(saved)).apply(saved);
    }

    @Auditable(action = "UPDATE", entity = "GRADE")
    @Transactional
    public GradeResponse update(Integer id, GradeRequest request) {
        Grade grade = findActive(id);
        if (!grade.getEnrollmentId().equals(request.enrollmentId())
                || !grade.getSubjectId().equals(request.subjectId())) {
            throw AppException.badRequest("Enrollment and subject of a grade cannot be changed");
        }
        apply(grade, request);
        Grade saved = gradeRepository.save(grade);
        return enrich(List.of(saved)).apply(saved);
    }

    @Auditable(action = "DELETE", entity = "GRADE")
    @Transactional
    public GradeResponse delete(Integer id) {
        Grade grade = findActive(id);
        grade.setStatus(Status.DELETED);
        Grade saved = gradeRepository.save(grade);
        return enrich(List.of(saved)).apply(saved);
    }

    private void apply(Grade grade, GradeRequest request) {
        grade.setScore(request.score());
        grade.setTerm(request.term());
        grade.setGradedBy(currentUsername());
    }

    private Grade findActive(Integer id) {
        return gradeRepository.findById(id)
                .filter(grade -> !Status.DELETED.equals(grade.getStatus()))
                .orElseThrow(() -> AppException.notFound("Grade not found"));
    }

    private String currentUsername() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null ? auth.getName() : null;
    }

    private Function<Grade, GradeResponse> enrich(List<Grade> grades) {
        Map<Integer, Subject> subjects = subjectRepository.findAllById(
                        grades.stream().map(Grade::getSubjectId).distinct().toList())
                .stream().collect(Collectors.toMap(Subject::getId, Function.identity()));

        return grade -> {
            Subject subject = subjects.get(grade.getSubjectId());
            return new GradeResponse(grade.getId(), grade.getEnrollmentId(), grade.getSubjectId(),
                    subject != null ? subject.getSubjectCode() : null,
                    subject != null ? subject.getName() : null,
                    grade.getScore(), grade.getTerm(), grade.getGradedBy());
        };
    }
}
