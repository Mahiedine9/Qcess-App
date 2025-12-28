package univ.lille.module_notification.application.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import univ.lille.module_notification.domain.model.Notification;
import univ.lille.module_notification.domain.port.in.DeviceTokenPort;
import univ.lille.module_notification.domain.port.in.PushNotificationPort;
import univ.lille.module_notification.domain.port.out.NotificationRepositoryPort;
import univ.lille.module_notification.domain.port.out.PushNotificationRepositoryPort;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class PushNotificationService implements PushNotificationPort {

    private final PushNotificationRepositoryPort pushNotification;
    private final DeviceTokenPort deviceTokenService;
    private final NotificationRepositoryPort notificationRepository;

    @Override
    public void sendToToken(String fcmToken, String title, String body, Map<String, String> data) {
        pushNotification.sendPushToToken(fcmToken, title, body, data);
    }

    @Override
    public void sendPushToUser(Long userId, String title, String body, String type, Map<String, String> data) {
        Notification notification = Notification.builder()
                .userId(userId)
                .title(title)
                .body(body)
                .type(type)
                .read(false)
                .build();
        notificationRepository.save(notification);
        log.debug("Notification stored for user {}", userId);

        List<String> tokens = deviceTokenService.getTokensByUserId(userId);
        if (tokens.isEmpty()) {
            log.warn("No FCM tokens found for user {}, notification stored but push not sent", userId);
            return;
        }
        for (String token : tokens) {
            pushNotification.sendPushToToken(token, title, body, data);
        }
        log.info("Push notification sent to {} device(s) for user {}", tokens.size(), userId);
    }

    @Override
    public void sendToOrganization(Long organizationId, String title, String body, String type, Map<String, String> data) {
        List<Long> userIds = deviceTokenService.getUserIdsByOrganizationId(organizationId);
        
        for (Long userId : userIds) {
            Notification notification = Notification.builder()
                    .userId(userId)
                    .title(title)
                    .body(body)
                    .type(type)
                    .read(false)
                    .build();
            notificationRepository.save(notification);
        }
        log.debug("Notifications stored for {} users in organization {}", userIds.size(), organizationId);

        List<String> tokens = deviceTokenService.getTokensByOrganizationId(organizationId);
        if (tokens.isEmpty()) {
            log.warn("No FCM tokens found for organization {}", organizationId);
            return;
        }
        for (String token : tokens) {
            pushNotification.sendPushToToken(token, title, body, data);
        }
        log.info("Broadcast notification sent to {} device(s) for organization {}", tokens.size(), organizationId);
    }
}
