package com.dinsaren.springbootjwtapi.startup;

import com.dinsaren.springbootjwtapi.registry.ApiMigrateRegistry;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class Startup {

    private final ApiMigrateRegistry apiMngRegistry;

    public Startup(ApiMigrateRegistry apiMngRegistry) {
        this.apiMngRegistry = apiMngRegistry;
    }

    private void init() {
        apiMngRegistry.loadComponent();
    }

    public void initApiMigrate() {
        log.info("Setting up Response code Manager context ...");
        this.init();
    }
}
