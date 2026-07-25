package com.school.management.dashboard;

import com.school.management.auditlog.AuditLog;
import com.school.management.auditlog.AuditLogRepository;
import com.school.management.common.constant.Status;
import com.school.management.enrollment.EnrollmentRepository;
import com.school.management.enrollment.EnrollmentService;
import com.school.management.enrollment.dto.EnrollmentDtos.EnrollmentResponse;
import com.school.management.masterdata.clazz.SchoolClassRepository;
import com.school.management.masterdata.student.StudentRepository;
import com.school.management.masterdata.subject.SubjectRepository;
import com.school.management.masterdata.teacher.TeacherRepository;
import com.school.management.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final SubjectRepository subjectRepository;
    private final SchoolClassRepository classRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final UserRepository userRepository;
    private final AuditLogRepository auditLogRepository;
    private final EnrollmentService enrollmentService;

    public record DashboardSummary(long students, long teachers, long subjects, long classes,
                                   long enrollments, long users,
                                   List<EnrollmentResponse> recentEnrollments,
                                   List<AuditLog> recentActivities) {
    }

    @Transactional(readOnly = true)
    public DashboardSummary summary() {
        return new DashboardSummary(
                studentRepository.countByStatus(Status.ACTIVE),
                teacherRepository.countByStatus(Status.ACTIVE),
                subjectRepository.countByStatus(Status.ACTIVE),
                classRepository.countByStatus(Status.ACTIVE),
                enrollmentRepository.countByStatus(Status.ACTIVE),
                userRepository.countByStatus(Status.ACTIVE),
                enrollmentService.recent(),
                auditLogRepository.findTop5ByOrderByIdDesc());
    }
}
