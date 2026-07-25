package com.school.management.common.exception;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ErrorResponse(String code, String message, List<FieldErrorItem> errors) {

    public record FieldErrorItem(String field, String message) {
    }

    public static ErrorResponse of(String code, String message) {
        return new ErrorResponse(code, message, null);
    }
}
