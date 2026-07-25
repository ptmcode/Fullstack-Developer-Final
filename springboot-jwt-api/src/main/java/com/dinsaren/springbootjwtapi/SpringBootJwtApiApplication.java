package com.dinsaren.springbootjwtapi;

import com.dinsaren.springbootjwtapi.startup.Startup;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;

@SpringBootApplication
@Slf4j
@Configuration
public class SpringBootJwtApiApplication extends SpringBootServletInitializer {
    private final Startup startup;

    public SpringBootJwtApiApplication(Startup startup) {
        this.startup = startup;
    }

    public static void main(String[] args) {
        SpringApplication.run(SpringBootJwtApiApplication.class, args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        return builder.sources(SpringBootJwtApiApplication.class);
    }

    @PostConstruct
    private void init() {
        log.info("Initializing Application ...");
        log.info("Initializing Response Manager ...");
        startup.initApiMigrate();
    }
}
