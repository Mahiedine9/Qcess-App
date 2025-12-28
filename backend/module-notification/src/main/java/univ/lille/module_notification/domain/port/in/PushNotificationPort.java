package univ.lille.module_notification.domain.port.in;

import java.util.Map;

public interface PushNotificationPort {

    void sendToToken(String fcmToken, String title, String body, Map<String, String> data);

    void sendPushToUser(Long userId, String title, String body, String type, Map<String, String> data);
    
    void sendToOrganization(Long organizationId, String title, String body, String type, Map<String, String> data);
}
