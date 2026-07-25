package com.school.management.masterdata.clazz;

import com.school.management.common.api.PageResponse;
import com.school.management.common.audit.Auditable;
import com.school.management.common.constant.Status;
import com.school.management.common.exception.AppException;
import com.school.management.masterdata.clazz.ClassDtos.ClassRequest;
import com.school.management.masterdata.clazz.ClassDtos.ClassResponse;
import com.school.management.masterdata.teacher.Teacher;
import com.school.management.masterdata.teacher.TeacherRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SchoolClassService {

    private final SchoolClassRepository classRepository;
    private final TeacherRepository teacherRepository;

    @Transactional(readOnly = true)
    public PageResponse<ClassResponse> list(String search, Pageable pageable) {
        Page<SchoolClass> page = classRepository.search(search == null ? "" : search.trim(), pageable);
        Map<Integer, String> teacherNames = teacherNames(page.getContent());
        return PageResponse.from(page, clazz -> toResponse(clazz, teacherNames));
    }

    @Transactional(readOnly = true)
    public ClassResponse get(Integer id) {
        SchoolClass clazz = findActive(id);
        return toResponse(clazz, teacherNames(List.of(clazz)));
    }

    @Auditable(action = "CREATE", entity = "CLASS")
    @Transactional
    public ClassResponse create(ClassRequest request) {
        classRepository.findByClassCode(request.classCode()).ifPresent(existing -> {
            throw AppException.conflict("Class code already exists");
        });
        SchoolClass clazz = new SchoolClass();
        clazz.setClassCode(request.classCode());
        apply(clazz, request);
        clazz.setStatus(Status.ACTIVE);
        SchoolClass saved = classRepository.save(clazz);
        return toResponse(saved, teacherNames(List.of(saved)));
    }

    @Auditable(action = "UPDATE", entity = "CLASS")
    @Transactional
    public ClassResponse update(Integer id, ClassRequest request) {
        SchoolClass clazz = findActive(id);
        classRepository.findByClassCode(request.classCode())
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw AppException.conflict("Class code already exists");
                });
        clazz.setClassCode(request.classCode());
        apply(clazz, request);
        SchoolClass saved = classRepository.save(clazz);
        return toResponse(saved, teacherNames(List.of(saved)));
    }

    @Auditable(action = "DELETE", entity = "CLASS")
    @Transactional
    public ClassResponse delete(Integer id) {
        SchoolClass clazz = findActive(id);
        clazz.setStatus(Status.DELETED);
        SchoolClass saved = classRepository.save(clazz);
        return toResponse(saved, Map.of());
    }

    SchoolClass findActive(Integer id) {
        return classRepository.findById(id)
                .filter(clazz -> !Status.DELETED.equals(clazz.getStatus()))
                .orElseThrow(() -> AppException.notFound("Class not found"));
    }

    private void apply(SchoolClass clazz, ClassRequest request) {
        if (request.teacherId() != null) {
            teacherRepository.findById(request.teacherId())
                    .filter(teacher -> Status.ACTIVE.equals(teacher.getStatus()))
                    .orElseThrow(() -> AppException.badRequest("Homeroom teacher not found or inactive"));
        }
        clazz.setName(request.name());
        clazz.setAcademicYear(request.academicYear());
        clazz.setTeacherId(request.teacherId());
        clazz.setCapacity(request.capacity());
    }

    private Map<Integer, String> teacherNames(List<SchoolClass> classes) {
        List<Integer> ids = classes.stream().map(SchoolClass::getTeacherId)
                .filter(Objects::nonNull).distinct().toList();
        if (ids.isEmpty()) {
            return Map.of();
        }
        return teacherRepository.findAllById(ids).stream()
                .collect(Collectors.toMap(Teacher::getId,
                        teacher -> teacher.getFirstName() + " " + teacher.getLastName()));
    }

    private ClassResponse toResponse(SchoolClass clazz, Map<Integer, String> teacherNames) {
        String teacherName = clazz.getTeacherId() != null ? teacherNames.get(clazz.getTeacherId()) : null;
        return new ClassResponse(clazz.getId(), clazz.getClassCode(), clazz.getName(), clazz.getAcademicYear(),
                clazz.getTeacherId(), teacherName, clazz.getCapacity(), clazz.getStatus());
    }
}
