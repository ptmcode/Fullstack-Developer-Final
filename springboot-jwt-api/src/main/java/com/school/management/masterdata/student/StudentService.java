package com.school.management.masterdata.student;

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
public class StudentService {

    private final StudentRepository studentRepository;

    @Transactional(readOnly = true)
    public PageResponse<Student> list(String search, Pageable pageable) {
        return PageResponse.from(studentRepository.search(search == null ? "" : search.trim(), pageable));
    }

    @Transactional(readOnly = true)
    public Student get(Integer id) {
        return findActive(id);
    }

    @Auditable(action = "CREATE", entity = "STUDENT")
    @Transactional
    public Student create(StudentRequest request) {
        studentRepository.findByStudentCode(request.studentCode()).ifPresent(existing -> {
            throw AppException.conflict("Student code already exists");
        });
        Student student = new Student();
        apply(student, request);
        student.setStudentCode(request.studentCode());
        student.setStatus(Status.ACTIVE);
        return studentRepository.save(student);
    }

    @Auditable(action = "UPDATE", entity = "STUDENT")
    @Transactional
    public Student update(Integer id, StudentRequest request) {
        Student student = findActive(id);
        studentRepository.findByStudentCode(request.studentCode())
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw AppException.conflict("Student code already exists");
                });
        student.setStudentCode(request.studentCode());
        apply(student, request);
        return studentRepository.save(student);
    }

    @Auditable(action = "DELETE", entity = "STUDENT")
    @Transactional
    public Student delete(Integer id) {
        Student student = findActive(id);
        student.setStatus(Status.DELETED);
        return studentRepository.save(student);
    }

    private Student findActive(Integer id) {
        return studentRepository.findById(id)
                .filter(student -> !Status.DELETED.equals(student.getStatus()))
                .orElseThrow(() -> AppException.notFound("Student not found"));
    }

    private void apply(Student student, StudentRequest request) {
        student.setFirstName(request.firstName());
        student.setLastName(request.lastName());
        student.setGender(request.gender());
        student.setDateOfBirth(request.dateOfBirth());
        student.setEmail(request.email());
        student.setPhone(request.phone());
        student.setAddress(request.address());
    }
}
