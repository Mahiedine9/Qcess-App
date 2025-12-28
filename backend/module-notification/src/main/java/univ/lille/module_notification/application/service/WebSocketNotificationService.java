package univ.lille.module_notification.application.service;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;
import lombok.RequiredArgsConstructor;
import univ.lille.dto.notification.ResourceEventDTO;
import univ.lille.module_notification.domain.port.in.RealtimeNotificationPort;

@Component
@RequiredArgsConstructor
public class WebSocketNotificationService implements RealtimeNotificationPort {
    private final SimpMessagingTemplate simp;

    @Override
    public void sendToUser(Long userId, ResourceEventDTO payload) {
        simp.convertAndSendToUser(userId.toString(), "/queue/notifications", payload);
    }

    @Override
    public void sendToOrganization(Long orgId, ResourceEventDTO payload) {
        simp.convertAndSend("/topic/org." + orgId, payload);
    }
}