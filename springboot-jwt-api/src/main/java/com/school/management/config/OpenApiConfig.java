package com.school.management.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springdoc.core.customizers.OperationCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.access.prepost.PreAuthorize;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Configuration
public class OpenApiConfig {

    private static final String BEARER_AUTH = "bearerAuth";
    private static final Pattern AUTHORITY = Pattern.compile("hasAuthority\\('([^']+)'\\)");

    @Bean
    public OpenAPI openApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("School Management System API")
                        .description("REST API for the School Management System — authentication, "
                                + "user management, master data, enrollments, grades, push notifications "
                                + "(Firebase Cloud Messaging) and audit log.\n\n"
                                + "Sign in with POST /api/v1/auth/login (admin/admin@123), then click "
                                + "Authorize and paste the accessToken.")
                        .version("v1.0")
                        .contact(new Contact()
                                .name("Sothea")
                                .email("keoleaphy@gmail.com")))
                .addSecurityItem(new SecurityRequirement().addList(BEARER_AUTH))
                .components(new Components()
                        .addSecuritySchemes(BEARER_AUTH, new SecurityScheme()
                                .name(BEARER_AUTH)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("Paste the access token from POST /api/v1/auth/login")));
    }

    /** Appends the endpoint's @PreAuthorize permission to its Swagger description. */
    @Bean
    public OperationCustomizer permissionDocumenter() {
        return (operation, handlerMethod) -> {
            PreAuthorize pre = handlerMethod.getMethodAnnotation(PreAuthorize.class);
            if (pre != null) {
                Matcher m = AUTHORITY.matcher(pre.value());
                if (m.find()) {
                    String base = operation.getDescription() == null ? "" : operation.getDescription() + " ";
                    operation.setDescription(base + "**Requires permission:** `" + m.group(1) + "`");
                }
            }
            return operation;
        };
    }
}
