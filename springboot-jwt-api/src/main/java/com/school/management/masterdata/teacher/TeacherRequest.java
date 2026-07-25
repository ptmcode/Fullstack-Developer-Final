package com.school.management.masterdata.teacher;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record TeacherRequest(
        @NotBlank(message = "Teacher code is required")
        @Size(max = 20, message = "Teacher code must be at most 20 characters") String teacherCode,
        @NotBlank(message = "First name is required") String firstName,
        @NotBlank(message = "Last name is required") String lastName,
        String gender,
        @Email(message = "Invalid email") String email,
        String phone,
        String specialization) {
}
