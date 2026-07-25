package com.school.management.masterdata.clazz;

import com.school.management.common.api.ApiResponse;
import com.school.management.common.api.PageResponse;
import com.school.management.common.api.Paging;
import com.school.management.masterdata.clazz.ClassDtos.ClassRequest;
import com.school.management.masterdata.clazz.ClassDtos.ClassResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/classes")
@RequiredArgsConstructor
@Tag(name = "Classes", description = "Class master data")
public class SchoolClassController {

    private final SchoolClassService classService;

    @GetMapping
    @PreAuthorize("hasAuthority('class.read')")
    @Operation(summary = "List classes", description = "Paginated, searchable by code, name and academic year")
    public ApiResponse<PageResponse<ClassResponse>> list(
            @RequestParam(defaultValue = "") String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id,desc") String sort) {
        return ApiResponse.ok(classService.list(search, Paging.of(page, size, sort)));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('class.read')")
    @Operation(summary = "Get class by id")
    public ApiResponse<ClassResponse> get(@PathVariable Integer id) {
        return ApiResponse.ok(classService.get(id));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('class.create')")
    @Operation(summary = "Create class")
    public ApiResponse<ClassResponse> create(@Valid @RequestBody ClassRequest request) {
        return ApiResponse.ok(classService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('class.update')")
    @Operation(summary = "Update class")
    public ApiResponse<ClassResponse> update(@PathVariable Integer id, @Valid @RequestBody ClassRequest request) {
        return ApiResponse.ok(classService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('class.delete')")
    @Operation(summary = "Delete class (soft delete)")
    public ApiResponse<ClassResponse> delete(@PathVariable Integer id) {
        return ApiResponse.ok(classService.delete(id));
    }
}
