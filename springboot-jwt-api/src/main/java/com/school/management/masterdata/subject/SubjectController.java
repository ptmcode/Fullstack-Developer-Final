package com.school.management.masterdata.subject;

import com.school.management.common.api.ApiResponse;
import com.school.management.common.api.PageResponse;
import com.school.management.common.api.Paging;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/subjects")
@RequiredArgsConstructor
@Tag(name = "Subjects", description = "Subject master data")
public class SubjectController {

    private final SubjectService subjectService;

    @GetMapping
    @PreAuthorize("hasAuthority('subject.read')")
    @Operation(summary = "List subjects", description = "Paginated, searchable by code and name")
    public ApiResponse<PageResponse<Subject>> list(
            @RequestParam(defaultValue = "") String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id,desc") String sort) {
        return ApiResponse.ok(subjectService.list(search, Paging.of(page, size, sort)));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('subject.read')")
    @Operation(summary = "Get subject by id")
    public ApiResponse<Subject> get(@PathVariable Integer id) {
        return ApiResponse.ok(subjectService.get(id));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('subject.create')")
    @Operation(summary = "Create subject")
    public ApiResponse<Subject> create(@Valid @RequestBody SubjectRequest request) {
        return ApiResponse.ok(subjectService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('subject.update')")
    @Operation(summary = "Update subject")
    public ApiResponse<Subject> update(@PathVariable Integer id, @Valid @RequestBody SubjectRequest request) {
        return ApiResponse.ok(subjectService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('subject.delete')")
    @Operation(summary = "Delete subject (soft delete)")
    public ApiResponse<Subject> delete(@PathVariable Integer id) {
        return ApiResponse.ok(subjectService.delete(id));
    }
}
