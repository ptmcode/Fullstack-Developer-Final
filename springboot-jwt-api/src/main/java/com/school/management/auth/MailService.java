package com.school.management.auth;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Demo mail sender: writes the message to the application log.
 * Swap for a real SMTP implementation (spring-boot-starter-mail) in production.
 */
@Slf4j
@Service
public class MailService {

    public void sendPasswordResetToken(String email, String token) {
        log.info("[MAIL] To: {} — Your password reset token is: {} (valid for a limited time, single use)",
                email, token);
    }
}
