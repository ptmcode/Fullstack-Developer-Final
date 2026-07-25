package com.school.management.masterdata.subject;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SubjectRequest(
        @NotBlank(message = "Subject code is required")
        @Size(max = 20, message = "Subject code must be at most 20 characters") String subjectCode,
        @NotBlank(message = "Subject name is required") String name,
        @Min(value = 1, message = "Credit must be at least 1")
        @Max(value = 20, message = "Credit must be at most 20") Integer credit,
        String description) {
}
