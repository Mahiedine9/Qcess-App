package univ.lille.module_notification.infrastructure.adapter.firebase;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.extern.slf4j.Slf4j;
import univ.lille.module_notification.domain.port.out.PushNotificationRepositoryPort;

import org.springframework.stereotype.Component;

import java.util.Map;

@Slf4j
@Component
public class FirebasePushNotificationAdapter implements PushNotificationRepositoryPort {

    @Override
    public void sendPushToToken(String fcmToken, String title, String body) {
        sendPushToToken(fcmToken, title, body, Map.of());
    }

    @Override
    public void sendPushToToken(String fcmToken, String title, String body, Map<String, String> data) {
        try {
            Message.Builder messageBuilder = Message.builder()
                .setToken(fcmToken)
                .setNotification(
                    Notification.builder()
                        .setTitle(title)
                        .setBody(body)
                        .build()
                );

            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }

            String response = FirebaseMessaging.getInstance().send(messageBuilder.build());
            log.info("Push notification sent successfully. Response: {}", response);
            
        } catch (FirebaseMessagingException e) {
            log.error("Failed to send push notification to token: {}. Error: {}", 
                    fcmToken.substring(0, Math.min(20, fcmToken.length())) + "...", 
                    e.getMessage());
        } catch (IllegalStateException e) {
            log.error("Firebase is not initialized. Cannot send push notification. Error: {}", e.getMessage());
        }
    }
}
