package univ.lille.module_notification.infrastructure.adapter.event;

import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import univ.lille.events.NotificationEvent;
import univ.lille.module_notification.domain.port.in.PushNotificationPort;
import univ.lille.module_notification.domain.port.in.RealtimeNotificationPort;
import univ.lille.module_notification.application.mapper.NotificationMapper;
import univ.lille.dto.notification.ResourceEventDTO;
import java.util.Map;
import java.util.stream.Collectors;


@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationEventListener {
    
    private final PushNotificationPort pushNotificationService;
    private final RealtimeNotificationPort realtimeNotificationService;
    private final NotificationMapper mapper;

    @Async
    @EventListener
    public void handleNotificationEvent(NotificationEvent event) {
        log.info("Received notification event: type={}, targetUser={}, targetOrg={}, title={}", 
            event.type(), event.targetUserId(), event.organizationId(), event.title());
        
        String type = event.type() != null ? event.type().name() : "UNKNOWN";
        
        ResourceEventDTO resource = mapper.toResourceEvent(event);

        if (event.targetUserId() != null) {
            realtimeNotificationService.sendToUser(event.targetUserId(), resource);
        } else if (event.organizationId() != null) {
            realtimeNotificationService.sendToOrganization(event.organizationId(), resource);
        }

        Map<String,String> fcmData = resource.getPayload().entrySet().stream()
            .collect(Collectors.toMap(Map.Entry::getKey, e -> String.valueOf(e.getValue())));
        fcmData.put("id", resource.getId());
        fcmData.put("timestamp", resource.getTimestamp());

        if (event.targetUserId() != null) {
            pushNotificationService.sendPushToUser(event.targetUserId(), resource.getPayload().get("title").toString(), resource.getPayload().get("body").toString(), type, fcmData);
        } else if (event.organizationId() != null) {
            pushNotificationService.sendToOrganization(event.organizationId(), resource.getPayload().get("title").toString(), resource.getPayload().get("body").toString(), type, fcmData);
        } else {
            log.warn("Notification event has no target (user or organization), skipping");
        }
    }
}