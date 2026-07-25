package com.school.management.common.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class AppException extends RuntimeException {

    private final HttpStatus status;
    private final String code;

    public AppException(HttpStatus status, String code, String message) {
        super(message);
        this.status = status;
        this.code = code;
    }

    public static AppException badRequest(String message) {
        return new AppException(HttpStatus.BAD_REQUEST, "E400", message);
    }

    public static AppException unauthorized(String message) {
        return new AppException(HttpStatus.UNAUTHORIZED, "E401", message);
    }

    public static AppException forbidden(String message) {
        return new AppException(HttpStatus.FORBIDDEN, "E403", message);
    }

    public static AppException notFound(String message) {
        return new AppException(HttpStatus.NOT_FOUND, "E404", message);
    }

    public static AppException conflict(String message) {
        return new AppException(HttpStatus.CONFLICT, "E409", message);
    }
}
