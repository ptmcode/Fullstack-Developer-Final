package com.dinsaren.springbootjwtapi.services.impl;

import com.dinsaren.springbootjwtapi.models.notification.PushNotificationRequest;
import com.dinsaren.springbootjwtapi.models.notification.PushNotificationResponse;
import com.dinsaren.springbootjwtapi.services.PushNotificationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;


@Service
@Slf4j
public class PushNotificationServiceImpl implements PushNotificationService {

    private RestTemplate restTemplate = new RestTemplate();
    private String baseUrl = "https://fcm.googleapis.com/fcm/send";
    private String key = "key=AAAA9nmKwMU:APA91bEKdRF1IPABR_8PFzlxoaoo3LVjKnl70O1BEggE3eFnUj7OcuvqggyWOrIcFSQjrQ41T7bNwMA67IEqQbnc5paNiu3Bf3c9FoH97DlOBil8bgYlAXdDQ3VhPk0VbGQ8DCWyz4kv";

    private String contentType = "application/json";

    @Override
    public void sendPushNotification(PushNotificationRequest req) {
        log.info("Intercept push notification req {}", req);
        ResponseEntity<PushNotificationResponse> response = null;
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", key);
            HttpEntity<PushNotificationRequest> request = new HttpEntity<>(req, headers);
            response = restTemplate.postForEntity(baseUrl, request, PushNotificationResponse.class);
        } catch (Throwable e) {
            log.info("Error push notification to firebase");
        } finally {
            log.info("Push Notification Response {} ", response);
        }
    }
}
