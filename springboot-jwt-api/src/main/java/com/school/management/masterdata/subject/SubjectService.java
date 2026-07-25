package com.school.management.masterdata.subject;

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
public class SubjectService {

    private final SubjectRepository subjectRepository;

    @Transactional(readOnly = true)
    public PageResponse<Subject> list(String search, Pageable pageable) {
        return PageResponse.from(subjectRepository.search(search == null ? "" : search.trim(), pageable));
    }

    @Transactional(readOnly = true)
    public Subject get(Integer id) {
        return findActive(id);
    }

    @Auditable(action = "CREATE", entity = "SUBJECT")
    @Transactional
    public Subject create(SubjectRequest request) {
        subjectRepository.findBySubjectCode(request.subjectCode()).ifPresent(existing -> {
            throw AppException.conflict("Subject code already exists");
        });
        Subject subject = new Subject();
        subject.setSubjectCode(request.subjectCode());
        apply(subject, request);
        subject.setStatus(Status.ACTIVE);
        return subjectRepository.save(subject);
    }

    @Auditable(action = "UPDATE", entity = "SUBJECT")
    @Transactional
    public Subject update(Integer id, SubjectRequest request) {
        Subject subject = findActive(id);
        subjectRepository.findBySubjectCode(request.subjectCode())
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw AppException.conflict("Subject code already exists");
                });
        subject.setSubjectCode(request.subjectCode());
        apply(subject, request);
        return subjectRepository.save(subject);
    }

    @Auditable(action = "DELETE", entity = "SUBJECT")
    @Transactional
    public Subject delete(Integer id) {
        Subject subject = findActive(id);
        subject.setStatus(Status.DELETED);
        return subjectRepository.save(subject);
    }

    private Subject findActive(Integer id) {
        return subjectRepository.findById(id)
                .filter(subject -> !Status.DELETED.equals(subject.getStatus()))
                .orElseThrow(() -> AppException.notFound("Subject not found"));
    }

    private void apply(Subject subject, SubjectRequest request) {
        subject.setName(request.name());
        subject.setCredit(request.credit());
        subject.setDescription(request.description());
    }
}
