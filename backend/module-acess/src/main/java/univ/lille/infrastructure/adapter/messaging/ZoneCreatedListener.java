package univ.lille.infrastructure.adapter.messaging;

import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import univ.lille.domain.port.in.ZoneQrCodePort;
import univ.lille.events.ZoneCreatedEvent;

@Component 
@RequiredArgsConstructor
@Slf4j
public class ZoneCreatedListener {
    private final ZoneQrCodePort zoneQrCodePort; 
    
    @Async
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onZoneCreated(ZoneCreatedEvent event) {
        log.info("Received ZoneCreatedEvent: zoneId={}, orgId={}, name={}", 
                 event.getZoneId(), event.getOrganizationId(), event.getName());   
        try {
            zoneQrCodePort.createForZone(event.getZoneId(), event.getOrganizationId(), event.getName());
            log.info("QR Code generated successfully for zone: {}", event.getZoneId());
        } catch (Exception e) {
            log.error("Error generating QR Code for zone: {}", event.getZoneId(), e);
        }
    }
}
