package com.school.management.masterdata.teacher;

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
@RequestMapping("/api/v1/teachers")
@RequiredArgsConstructor
@Tag(name = "Teachers", description = "Teacher master data")
public class TeacherController {

    private final TeacherService teacherService;

    @GetMapping
    @PreAuthorize("hasAuthority('teacher.read')")
    @Operation(summary = "List teachers", description = "Paginated, searchable by code, name and specialization")
    public ApiResponse<PageResponse<Teacher>> list(
            @RequestParam(defaultValue = "") String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id,desc") String sort) {
        return ApiResponse.ok(teacherService.list(search, Paging.of(page, size, sort)));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('teacher.read')")
    @Operation(summary = "Get teacher by id")
    public ApiResponse<Teacher> get(@PathVariable Integer id) {
        return ApiResponse.ok(teacherService.get(id));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('teacher.create')")
    @Operation(summary = "Create teacher")
    public ApiResponse<Teacher> create(@Valid @RequestBody TeacherRequest request) {
        return ApiResponse.ok(teacherService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('teacher.update')")
    @Operation(summary = "Update teacher")
    public ApiResponse<Teacher> update(@PathVariable Integer id, @Valid @RequestBody TeacherRequest request) {
        return ApiResponse.ok(teacherService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('teacher.delete')")
    @Operation(summary = "Delete teacher (soft delete)")
    public ApiResponse<Teacher> delete(@PathVariable Integer id) {
        return ApiResponse.ok(teacherService.delete(id));
    }
}
