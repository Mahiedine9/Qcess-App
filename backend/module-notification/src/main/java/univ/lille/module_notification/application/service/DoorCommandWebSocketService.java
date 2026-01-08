package univ.lille.module_notification.application.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;
import univ.lille.door.DoorCommandPort;
import univ.lille.module_notification.dto.DoorCommandMessage;

@Component
@RequiredArgsConstructor
@Slf4j
public class DoorCommandWebSocketService implements DoorCommandPort {

    private final SimpMessagingTemplate simpMessagingTemplate;

    @Override
    public void sendCommand(String command) {
        DoorCommandMessage payload = new DoorCommandMessage(command);
        log.info("[DoorCommand] Envoi commande porte: {} vers /topic/door-control", command);
        simpMessagingTemplate.convertAndSend("/topic/door-control", payload);
    }
}