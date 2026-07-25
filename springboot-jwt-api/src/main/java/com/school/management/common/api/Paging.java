package com.school.management.common.api;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

public final class Paging {

    private Paging() {
    }

    /** Builds a Pageable from request params; sort format: "field,asc|desc". */
    public static Pageable of(int page, int size, String sort) {
        Sort sortSpec = Sort.by(Sort.Direction.DESC, "id");
        if (sort != null && !sort.isBlank()) {
            String[] parts = sort.split(",");
            Sort.Direction direction = parts.length > 1 && "asc".equalsIgnoreCase(parts[1].trim())
                    ? Sort.Direction.ASC : Sort.Direction.DESC;
            sortSpec = Sort.by(direction, parts[0].trim());
        }
        return PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100), sortSpec);
    }
}
