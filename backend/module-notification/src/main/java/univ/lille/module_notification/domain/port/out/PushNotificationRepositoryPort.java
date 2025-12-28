package univ.lille.module_notification.domain.port.out;

import java.util.Map;

public interface PushNotificationRepositoryPort {
    void sendPushToToken(String fcmToken, String title, String body);
    
    void sendPushToToken(String fcmToken, String title, String body, Map<String, String> data);
}
