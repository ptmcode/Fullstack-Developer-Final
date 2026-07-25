package com.school.management.enrollment.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public final class EnrollmentDtos {

    private EnrollmentDtos() {
    }

    public record EnrollmentRequest(
            @NotNull(message = "Student is required") Integer studentId,
            @NotNull(message = "Class is required") Integer classId) {
    }

    public record EnrollmentResponse(Integer id, Integer studentId, String studentCode, String studentName,
                                     Integer classId, String classCode, String className,
                                     LocalDateTime enrolledAt, String status) {
    }

    public record GradeRequest(
            @NotNull(message = "Enrollment is required") Integer enrollmentId,
            @NotNull(message = "Subject is required") Integer subjectId,
            @NotNull(message = "Score is required")
            @DecimalMin(value = "0.0", message = "Score must be at least 0")
            @DecimalMax(value = "100.0", message = "Score must be at most 100") BigDecimal score,
            @NotBlank(message = "Term is required") String term) {
    }

    public record GradeResponse(Integer id, Integer enrollmentId, Integer subjectId, String subjectCode,
                                String subjectName, BigDecimal score, String term, String gradedBy) {
    }
}
