package univ.lille.module_notification.domain.port.in;

import univ.lille.dto.notification.ResourceEventDTO;


public interface RealtimeNotificationPort {
    void sendToUser(Long userId, ResourceEventDTO payload);
    void sendToOrganization(Long orgId, ResourceEventDTO payload);
}