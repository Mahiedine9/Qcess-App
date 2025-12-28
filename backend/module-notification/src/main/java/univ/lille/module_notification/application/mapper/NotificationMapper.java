package univ.lille.module_notification.application.mapper;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Component;

import univ.lille.dto.notification.ResourceEventDTO;
import univ.lille.events.NotificationEvent;

@Component
public class NotificationMapper {

    public ResourceEventDTO toResourceEvent(NotificationEvent event) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", event.type() != null ? event.type().name() : "UNKNOWN");
        payload.put("title", event.title());
        payload.put("body", event.body());
        
        if (event.data() != null) payload.putAll(event.data());

        return ResourceEventDTO.builder()
                .id(UUID.randomUUID().toString())
                .timestamp(Instant.now().toString())
                .resourceType("notification")
                .resourceId(event.targetUserId() != null ? event.targetUserId() : event.organizationId())
                .payload(payload)
                .build();
    }
}
