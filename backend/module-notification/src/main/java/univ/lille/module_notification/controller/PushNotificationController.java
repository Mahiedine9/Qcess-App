package univ.lille.module_notification.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import univ.lille.module_notification.application.dto.SendNotificationRequest;
import univ.lille.module_notification.application.dto.SendNotificationResponse;
import univ.lille.module_notification.application.dto.SendToTokenRequest;
import univ.lille.module_notification.domain.port.in.PushNotificationPort;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class PushNotificationController {

    private final PushNotificationPort pushNotificationService;

    @PostMapping("/send")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SendNotificationResponse> sendNotification(
            @Valid @RequestBody SendNotificationRequest request) {
        log.info("Admin sending push notification to user {}: {}", request.userId(), request.title());
        pushNotificationService.sendPushToUser(Long.valueOf(request.userId()), request.title(), request.body(), "MANUAL", Map.of());
        return ResponseEntity.ok(SendNotificationResponse.success("Notification envoyée avec succès"));
    }

    @PostMapping("/send-to-token")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SendNotificationResponse> sendToToken(
            @Valid @RequestBody SendToTokenRequest request) {
        log.info("Admin sending push notification to token: {}", request.title());
        pushNotificationService.sendToToken(request.fcmToken(), request.title(), request.body(), Map.of());
        return ResponseEntity.ok(SendNotificationResponse.success("Notification envoyée avec succès"));
    }
}
