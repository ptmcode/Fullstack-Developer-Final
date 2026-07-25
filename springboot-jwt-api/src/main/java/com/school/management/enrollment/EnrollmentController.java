package com.school.management.enrollment;

import com.school.management.common.api.ApiResponse;
import com.school.management.common.api.PageResponse;
import com.school.management.common.api.Paging;
import com.school.management.enrollment.dto.EnrollmentDtos.EnrollmentRequest;
import com.school.management.enrollment.dto.EnrollmentDtos.EnrollmentResponse;
import com.school.management.enrollment.dto.EnrollmentDtos.GradeResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Tag(name = "Enrollments", description = "Enroll students into classes")
public class EnrollmentController {

    private final EnrollmentService enrollmentService;
    private final GradeService gradeService;

    @GetMapping("/enrollments")
    @PreAuthorize("hasAuthority('enrollment.read')")
    @Operation(summary = "List enrollments", description = "Paginated; optional studentId / classId filters")
    public ApiResponse<PageResponse<EnrollmentResponse>> list(
            @RequestParam(required = false) Integer studentId,
            @RequestParam(required = false) Integer classId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id,desc") String sort) {
        return ApiResponse.ok(enrollmentService.list(studentId, classId, Paging.of(page, size, sort)));
    }

    @PostMapping("/enrollments")
    @PreAuthorize("hasAuthority('enrollment.create')")
    @Operation(summary = "Enroll a student into a class")
    public ApiResponse<EnrollmentResponse> enroll(@Valid @RequestBody EnrollmentRequest request) {
        return ApiResponse.ok(enrollmentService.enroll(request));
    }

    @DeleteMapping("/enrollments/{id}")
    @PreAuthorize("hasAuthority('enrollment.delete')")
    @Operation(summary = "Remove an enrollment (soft delete)")
    public ApiResponse<EnrollmentResponse> delete(@PathVariable Integer id) {
        return ApiResponse.ok(enrollmentService.delete(id));
    }

    @GetMapping("/classes/{classId}/enrollments")
    @PreAuthorize("hasAuthority('enrollment.read')")
    @Operation(summary = "List enrollments of a class")
    public ApiResponse<List<EnrollmentResponse>> byClass(@PathVariable Integer classId) {
        return ApiResponse.ok(enrollmentService.listByClass(classId));
    }

    @GetMapping("/students/{studentId}/enrollments")
    @PreAuthorize("hasAuthority('enrollment.read')")
    @Operation(summary = "List enrollments of a student")
    public ApiResponse<List<EnrollmentResponse>> byStudent(@PathVariable Integer studentId) {
        return ApiResponse.ok(enrollmentService.listByStudent(studentId));
    }

    @GetMapping("/enrollments/{id}/grades")
    @PreAuthorize("hasAuthority('grade.read')")
    @Operation(summary = "List grades of an enrollment")
    public ApiResponse<List<GradeResponse>> grades(@PathVariable Integer id) {
        return ApiResponse.ok(gradeService.listByEnrollment(id));
    }

    @GetMapping("/students/{studentId}/grades")
    @PreAuthorize("hasAuthority('grade.read')")
    @Operation(summary = "List all grades of a student")
    public ApiResponse<List<GradeResponse>> studentGrades(@PathVariable Integer studentId) {
        return ApiResponse.ok(gradeService.listByStudent(studentId));
    }
}
