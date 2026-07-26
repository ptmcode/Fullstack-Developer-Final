package com.school.management.notification;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.MessagingErrorCode;
import com.google.firebase.messaging.MulticastMessage;
import com.google.firebase.messaging.SendResponse;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Thin wrapper around Firebase Cloud Messaging.
 *
 * <p>Without a service account key the client stays in <em>dry-run</em> mode: payloads are
 * written to the log instead of being delivered, so the application runs unchanged on
 * machines that have no Firebase project configured.
 */
@Slf4j
@Component
public class FirebaseMessagingClient {

    private static final String CLASSPATH_PREFIX = "classpath:";

    @Value("${app.firebase.enabled:true}")
    private boolean enabled;

    @Value("${app.firebase.credentials-path:}")
    private String credentialsPath;

    @Value("${app.firebase.project-id:}")
    private String projectId;

    private FirebaseMessaging messaging;

    @PostConstruct
    void init() {
        if (!enabled) {
            log.info("Firebase push is disabled by configuration (app.firebase.enabled=false) — dry-run mode");
            return;
        }
        try {
            GoogleCredentials credentials = loadCredentials();
            if (credentials == null) {
                log.warn("Firebase service account not found — push notifications run in dry-run mode. "
                        + "Set app.firebase.credentials-path (or GOOGLE_APPLICATION_CREDENTIALS) to enable delivery.");
                return;
            }
            FirebaseOptions.Builder options = FirebaseOptions.builder().setCredentials(credentials);
            if (StringUtils.hasText(projectId)) {
                options.setProjectId(projectId);
            }
            FirebaseApp app = FirebaseApp.getApps().isEmpty()
                    ? FirebaseApp.initializeApp(options.build())
                    : FirebaseApp.getInstance();
            messaging = FirebaseMessaging.getInstance(app);
            log.info("Firebase Cloud Messaging initialised — push notifications are live");
        } catch (Exception e) {
            log.error("Firebase initialisation failed — falling back to dry-run mode: {}", e.getMessage());
        }
    }

    /** Accepts a "classpath:..." location or a filesystem path. */
    private GoogleCredentials loadCredentials() throws Exception {
        if (StringUtils.hasText(credentialsPath)) {
            if (credentialsPath.startsWith(CLASSPATH_PREFIX)) {
                String resource = credentialsPath.substring(CLASSPATH_PREFIX.length());
                try (InputStream in = getClass().getClassLoader().getResourceAsStream(resource)) {
                    if (in == null) {
                        log.warn("Firebase credentials not found on classpath: {}", resource);
                        return null;
                    }
                    return GoogleCredentials.fromStream(in);
                }
            }
            Path path = Path.of(credentialsPath);
            if (!Files.isRegularFile(path)) {
                log.warn("Firebase credentials file not found at {}", path.toAbsolutePath());
                return null;
            }
            try (InputStream in = new FileInputStream(path.toFile())) {
                return GoogleCredentials.fromStream(in);
            }
        }
        if (StringUtils.hasText(System.getenv("GOOGLE_APPLICATION_CREDENTIALS"))) {
            return GoogleCredentials.getApplicationDefault();
        }
        return null;
    }

    public boolean isEnabled() {
        return messaging != null;
    }

    /**
     * Delivers one notification to many device tokens.
     *
     * @return tokens FCM rejected as permanently invalid — the caller should deactivate them
     */
    public List<String> send(List<String> tokens, String title, String body, Map<String, String> data) {
        if (tokens.isEmpty()) {
            return List.of();
        }
        if (messaging == null) {
            log.info("[PUSH dry-run] {} device(s) | {} | {} | data={}", tokens.size(), title, body, data);
            return List.of();
        }
        try {
            MulticastMessage message = MulticastMessage.builder()
                    .addAllTokens(tokens)
                    .setNotification(com.google.firebase.messaging.Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .putAllData(data)
                    .build();

            BatchResponse response = messaging.sendEachForMulticast(message);
            log.info("Push sent: {} succeeded, {} failed", response.getSuccessCount(), response.getFailureCount());

            List<String> invalidTokens = new ArrayList<>();
            List<SendResponse> responses = response.getResponses();
            for (int i = 0; i < responses.size(); i++) {
                SendResponse each = responses.get(i);
                if (each.isSuccessful() || each.getException() == null) {
                    continue;
                }
                MessagingErrorCode code = each.getException().getMessagingErrorCode();
                if (code == MessagingErrorCode.UNREGISTERED || code == MessagingErrorCode.INVALID_ARGUMENT) {
                    invalidTokens.add(tokens.get(i));
                }
            }
            return invalidTokens;
        } catch (Exception e) {
            log.error("Failed to send push notification: {}", e.getMessage());
            return List.of();
        }
    }
}
