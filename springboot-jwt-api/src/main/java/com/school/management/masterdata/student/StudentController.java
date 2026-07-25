package com.school.management.masterdata.student;

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
@RequestMapping("/api/v1/students")
@RequiredArgsConstructor
@Tag(name = "Students", description = "Student master data")
public class StudentController {

    private final StudentService studentService;

    @GetMapping
    @PreAuthorize("hasAuthority('student.read')")
    @Operation(summary = "List students", description = "Paginated, searchable by code and name")
    public ApiResponse<PageResponse<Student>> list(
            @RequestParam(defaultValue = "") String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id,desc") String sort) {
        return ApiResponse.ok(studentService.list(search, Paging.of(page, size, sort)));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('student.read')")
    @Operation(summary = "Get student by id")
    public ApiResponse<Student> get(@PathVariable Integer id) {
        return ApiResponse.ok(studentService.get(id));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('student.create')")
    @Operation(summary = "Create student")
    public ApiResponse<Student> create(@Valid @RequestBody StudentRequest request) {
        return ApiResponse.ok(studentService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('student.update')")
    @Operation(summary = "Update student")
    public ApiResponse<Student> update(@PathVariable Integer id, @Valid @RequestBody StudentRequest request) {
        return ApiResponse.ok(studentService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('student.delete')")
    @Operation(summary = "Delete student (soft delete)")
    public ApiResponse<Student> delete(@PathVariable Integer id) {
        return ApiResponse.ok(studentService.delete(id));
    }
}
