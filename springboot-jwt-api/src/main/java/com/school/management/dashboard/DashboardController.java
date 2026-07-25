package com.school.management.dashboard;

import com.school.management.common.api.ApiResponse;
import com.school.management.dashboard.DashboardService.DashboardSummary;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
@Tag(name = "Dashboard", description = "Summary statistics and recent activity")
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/summary")
    @PreAuthorize("hasAuthority('dashboard.read')")
    @Operation(summary = "Dashboard summary", description = "Active counts plus recent enrollments and audit entries")
    public ApiResponse<DashboardSummary> summary() {
        return ApiResponse.ok(dashboardService.summary());
    }
}
