package com.school.management.masterdata.teacher;

import com.school.management.common.api.PageResponse;
import com.school.management.common.audit.Auditable;
import com.school.management.common.constant.Status;
import com.school.management.common.exception.AppException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TeacherService {

    private final TeacherRepository teacherRepository;

    @Transactional(readOnly = true)
    public PageResponse<Teacher> list(String search, Pageable pageable) {
        return PageResponse.from(teacherRepository.search(search == null ? "" : search.trim(), pageable));
    }

    @Transactional(readOnly = true)
    public Teacher get(Integer id) {
        return findActive(id);
    }

    @Auditable(action = "CREATE", entity = "TEACHER")
    @Transactional
    public Teacher create(TeacherRequest request) {
        teacherRepository.findByTeacherCode(request.teacherCode()).ifPresent(existing -> {
            throw AppException.conflict("Teacher code already exists");
        });
        Teacher teacher = new Teacher();
        teacher.setTeacherCode(request.teacherCode());
        apply(teacher, request);
        teacher.setStatus(Status.ACTIVE);
        return teacherRepository.save(teacher);
    }

    @Auditable(action = "UPDATE", entity = "TEACHER")
    @Transactional
    public Teacher update(Integer id, TeacherRequest request) {
        Teacher teacher = findActive(id);
        teacherRepository.findByTeacherCode(request.teacherCode())
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw AppException.conflict("Teacher code already exists");
                });
        teacher.setTeacherCode(request.teacherCode());
        apply(teacher, request);
        return teacherRepository.save(teacher);
    }

    @Auditable(action = "DELETE", entity = "TEACHER")
    @Transactional
    public Teacher delete(Integer id) {
        Teacher teacher = findActive(id);
        teacher.setStatus(Status.DELETED);
        return teacherRepository.save(teacher);
    }

    private Teacher findActive(Integer id) {
        return teacherRepository.findById(id)
                .filter(teacher -> !Status.DELETED.equals(teacher.getStatus()))
                .orElseThrow(() -> AppException.notFound("Teacher not found"));
    }

    private void apply(Teacher teacher, TeacherRequest request) {
        teacher.setFirstName(request.firstName());
        teacher.setLastName(request.lastName());
        teacher.setGender(request.gender());
        teacher.setEmail(request.email());
        teacher.setPhone(request.phone());
        teacher.setSpecialization(request.specialization());
    }
}
