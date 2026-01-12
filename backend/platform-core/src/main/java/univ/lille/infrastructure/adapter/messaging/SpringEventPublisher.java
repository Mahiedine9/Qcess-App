package univ.lille.infrastructure.adapter.messaging;

import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;
import univ.lille.domain.port.out.ZoneEventPublisher;
import univ.lille.events.ZoneCreatedEvent;

@Component
@RequiredArgsConstructor
public class SpringEventPublisher implements ZoneEventPublisher {
    private final ApplicationEventPublisher eventPublisher;

    @Override
    public void publishZoneCreated(ZoneCreatedEvent event) {
        eventPublisher.publishEvent(event);
    }
}
