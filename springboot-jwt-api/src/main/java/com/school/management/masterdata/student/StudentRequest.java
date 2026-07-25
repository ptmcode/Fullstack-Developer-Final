package com.school.management.masterdata.student;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record StudentRequest(
        @NotBlank(message = "Student code is required")
        @Size(max = 20, message = "Student code must be at most 20 characters") String studentCode,
        @NotBlank(message = "First name is required") String firstName,
        @NotBlank(message = "Last name is required") String lastName,
        String gender,
        @Past(message = "Date of birth must be in the past") LocalDate dateOfBirth,
        @Email(message = "Invalid email") String email,
        String phone,
        String address) {
}
