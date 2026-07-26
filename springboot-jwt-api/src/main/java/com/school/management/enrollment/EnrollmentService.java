package com.school.management.enrollment;

import com.school.management.common.api.PageResponse;
import com.school.management.common.audit.Auditable;
import com.school.management.common.constant.Status;
import com.school.management.common.exception.AppException;
import com.school.management.enrollment.dto.EnrollmentDtos.EnrollmentRequest;
import com.school.management.enrollment.dto.EnrollmentDtos.EnrollmentResponse;
import com.school.management.masterdata.clazz.SchoolClass;
import com.school.management.masterdata.clazz.SchoolClassRepository;
import com.school.management.masterdata.student.Student;
import com.school.management.masterdata.student.StudentRepository;
import com.school.management.notification.PushNotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EnrollmentService {

    private final EnrollmentRepository enrollmentRepository;
    private final StudentRepository studentRepository;
    private final SchoolClassRepository classRepository;
    private final PushNotificationService pushNotificationService;

    @Transactional(readOnly = true)
    public PageResponse<EnrollmentResponse> list(Integer studentId, Integer classId, Pageable pageable) {
        Page<Enrollment> page = enrollmentRepository.search(
                studentId == null ? 0 : studentId, classId == null ? 0 : classId, pageable);
        return PageResponse.from(page, enrich(page.getContent()));
    }

    @Transactional(readOnly = true)
    public List<EnrollmentResponse> listByClass(Integer classId) {
        List<Enrollment> enrollments = enrollmentRepository.findByClassIdAndStatus(classId, Status.ACTIVE);
        return enrollments.stream().map(enrich(enrollments)).toList();
    }

    @Transactional(readOnly = true)
    public List<EnrollmentResponse> listByStudent(Integer studentId) {
        List<Enrollment> enrollments = enrollmentRepository.findByStudentIdAndStatus(studentId, Status.ACTIVE);
        return enrollments.stream().map(enrich(enrollments)).toList();
    }

    /** Used by the dashboard. */
    @Transactional(readOnly = true)
    public List<EnrollmentResponse> recent() {
        List<Enrollment> enrollments = enrollmentRepository.findTop5ByStatusOrderByIdDesc(Status.ACTIVE);
        return enrollments.stream().map(enrich(enrollments)).toList();
    }

    @Auditable(action = "CREATE", entity = "ENROLLMENT")
    @Transactional
    public EnrollmentResponse enroll(EnrollmentRequest request) {
        Student student = studentRepository.findById(request.studentId())
                .filter(s -> Status.ACTIVE.equals(s.getStatus()))
                .orElseThrow(() -> AppException.badRequest("Student not found or inactive"));
        SchoolClass clazz = classRepository.findById(request.classId())
                .filter(c -> Status.ACTIVE.equals(c.getStatus()))
                .orElseThrow(() -> AppException.badRequest("Class not found or inactive"));

        if (clazz.getCapacity() != null
                && enrollmentRepository.countByClassIdAndStatus(clazz.getId(), Status.ACTIVE) >= clazz.getCapacity()) {
            throw AppException.conflict("Class is full (capacity " + clazz.getCapacity() + ")");
        }

        // The DB has UNIQUE(student_id, class_id); a soft-deleted enrollment is re-activated.
        Enrollment enrollment = enrollmentRepository
                .findByStudentIdAndClassId(student.getId(), clazz.getId())
                .map(existing -> {
                    if (Status.ACTIVE.equals(existing.getStatus())) {
                        throw AppException.conflict("Student is already enrolled in this class");
                    }
                    existing.setStatus(Status.ACTIVE);
                    existing.setEnrolledAt(LocalDateTime.now());
                    return existing;
                })
                .orElseGet(() -> {
                    Enrollment created = new Enrollment();
                    created.setStudentId(student.getId());
                    created.setClassId(clazz.getId());
                    created.setEnrolledAt(LocalDateTime.now());
                    created.setStatus(Status.ACTIVE);
                    return created;
                });

        Enrollment saved = enrollmentRepository.save(enrollment);
        EnrollmentResponse response = enrich(List.of(saved)).apply(saved);
        if (student.getUserId() != null) {
            pushNotificationService.notifyUser(student.getUserId(), "Class enrollment",
                    "You have been enrolled in %s (%s)".formatted(clazz.getName(), clazz.getClassCode()),
                    PushNotificationService.TYPE_ENROLLMENT, "ENROLLMENT", String.valueOf(saved.getId()));
        }
        return response;
    }

    @Auditable(action = "DELETE", entity = "ENROLLMENT")
    @Transactional
    public EnrollmentResponse delete(Integer id) {
        Enrollment enrollment = findActive(id);
        enrollment.setStatus(Status.DELETED);
        Enrollment saved = enrollmentRepository.save(enrollment);
        return enrich(List.of(saved)).apply(saved);
    }

    Enrollment findActive(Integer id) {
        return enrollmentRepository.findById(id)
                .filter(enrollment -> !Status.DELETED.equals(enrollment.getStatus()))
                .orElseThrow(() -> AppException.notFound("Enrollment not found"));
    }

    /** Bulk-loads student and class display data for a set of enrollments. */
    private Function<Enrollment, EnrollmentResponse> enrich(List<Enrollment> enrollments) {
        Map<Integer, Student> students = studentRepository.findAllById(
                        enrollments.stream().map(Enrollment::getStudentId).distinct().toList())
                .stream().collect(Collectors.toMap(Student::getId, Function.identity()));
        Map<Integer, SchoolClass> classes = classRepository.findAllById(
                        enrollments.stream().map(Enrollment::getClassId).distinct().toList())
                .stream().collect(Collectors.toMap(SchoolClass::getId, Function.identity()));

        return enrollment -> {
            Student student = students.get(enrollment.getStudentId());
            SchoolClass clazz = classes.get(enrollment.getClassId());
            return new EnrollmentResponse(
                    enrollment.getId(),
                    enrollment.getStudentId(),
                    student != null ? student.getStudentCode() : null,
                    student != null ? student.getFirstName() + " " + student.getLastName() : null,
                    enrollment.getClassId(),
                    clazz != null ? clazz.getClassCode() : null,
                    clazz != null ? clazz.getName() : null,
                    enrollment.getEnrolledAt(),
                    enrollment.getStatus());
        };
    }
}
