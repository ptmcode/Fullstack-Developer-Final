package com.school.management.masterdata.clazz;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public final class ClassDtos {

    private ClassDtos() {
    }

    public record ClassRequest(
            @NotBlank(message = "Class code is required")
            @Size(max = 20, message = "Class code must be at most 20 characters") String classCode,
            @NotBlank(message = "Class name is required") String name,
            @Pattern(regexp = "^$|\\d{4}-\\d{4}", message = "Academic year must look like 2025-2026") String academicYear,
            Integer teacherId,
            @Min(value = 1, message = "Capacity must be at least 1") Integer capacity) {
    }

    public record ClassResponse(Integer id, String classCode, String name, String academicYear,
                                Integer teacherId, String teacherName, Integer capacity, String status) {
    }
}
