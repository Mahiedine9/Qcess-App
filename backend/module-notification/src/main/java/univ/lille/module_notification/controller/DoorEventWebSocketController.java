package univ.lille.module_notification.controller;

import lombok.extern.slf4j.Slf4j;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;
import univ.lille.module_notification.dto.DoorEventMessage;

/**
 * Reçoit les événements envoyés par le simulateur de porte via STOMP.
 *
 * Destination côté client : /app/door/events
 */
@Controller
@RequiredArgsConstructor
@Slf4j
public class DoorEventWebSocketController {

    @MessageMapping("/door/events")
    public void handleDoorEvent(@Payload DoorEventMessage message) {
        // Pour l'instant on se contente de logger l'événement.
        // Plus tard, on pourra :
        // - persister l'événement
        // - l'envoyer sur un topic /topic/door-events
        // - ou l'utiliser pour synchroniser d'autres vues.
        log.info("Door event received: type={}, state={}, deviceId={}, ts={}",
                message.getType(), message.getState(), message.getDeviceId(), message.getTimestamp());
    }
}
