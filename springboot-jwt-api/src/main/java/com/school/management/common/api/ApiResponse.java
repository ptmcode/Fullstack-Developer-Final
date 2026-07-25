package com.school.management.common.api;

public record ApiResponse<T>(String code, String message, T data) {

    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>("OK", "Success", data);
    }

    public static ApiResponse<Void> ok() {
        return new ApiResponse<>("OK", "Success", null);
    }

    public static ApiResponse<Void> message(String message) {
        return new ApiResponse<>("OK", message, null);
    }
}
