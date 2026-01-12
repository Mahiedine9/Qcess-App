package univ.lille.events;

import org.springframework.context.ApplicationEvent;
import lombok.Getter;

@Getter
public class ZoneCreatedEvent extends ApplicationEvent {

    private final Long zoneId;
    private final Long organizationId;
    private final String name;

    public ZoneCreatedEvent(Object source, Long zoneId, Long organizationId, String name) {
        super(source);
        this.zoneId = zoneId;
        this.organizationId = organizationId;
        this.name = name;
    }
}
