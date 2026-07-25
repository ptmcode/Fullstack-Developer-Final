package com.dinsaren.springbootjwtapi.registry;

import com.dinsaren.springbootjwtapi.caches.SmsCache;
import com.dinsaren.springbootjwtapi.services.OtpService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class ApiMigrateRegistry {

    private final OtpService otpService;

    public ApiMigrateRegistry(OtpService otpService) {
        this.otpService = otpService;
    }

    public void loadComponent() {
        log.info("Loading component ...");
        this.loadResponseCode();
    }

    private void loadResponseCode() {
        SmsCache.init();
        log.info("Init otp service ...");
        this.otpService.init();
    }

}
