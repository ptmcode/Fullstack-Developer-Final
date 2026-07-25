package com.school.management.enrollment;

import com.school.management.common.api.ApiResponse;
import com.school.management.enrollment.dto.EnrollmentDtos.GradeRequest;
import com.school.management.enrollment.dto.EnrollmentDtos.GradeResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/grades")
@RequiredArgsConstructor
@Tag(name = "Grades", description = "Record and manage grades per enrollment and subject")
public class GradeController {

    private final GradeService gradeService;

    @PostMapping
    @PreAuthorize("hasAuthority('grade.create')")
    @Operation(summary = "Record a grade", description = "Score 0-100, one grade per enrollment + subject + term")
    public ApiResponse<GradeResponse> record(@Valid @RequestBody GradeRequest request) {
        return ApiResponse.ok(gradeService.record(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('grade.update')")
    @Operation(summary = "Update a grade score")
    public ApiResponse<GradeResponse> update(@PathVariable Integer id, @Valid @RequestBody GradeRequest request) {
        return ApiResponse.ok(gradeService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('grade.delete')")
    @Operation(summary = "Delete a grade (soft delete)")
    public ApiResponse<GradeResponse> delete(@PathVariable Integer id) {
        return ApiResponse.ok(gradeService.delete(id));
    }
}
