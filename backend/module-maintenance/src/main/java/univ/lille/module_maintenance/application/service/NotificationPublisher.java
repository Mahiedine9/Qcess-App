package univ.lille.module_maintenance.application.service;

import java.util.Map;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import univ.lille.enums.NotificationType;
import univ.lille.events.NotificationEvent;
import univ.lille.module_maintenance.domain.model.Status;
import univ.lille.module_maintenance.domain.port.in.NotificationPublisherPort;


@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationPublisher implements NotificationPublisherPort {
    
    private static final String KEY_TICKET_ID = "ticketId";
    private static final String KEY_NEW_STATUS = "newStatus";
    
    private final ApplicationEventPublisher eventPublisher;



    public void notifyTicketStatusChanged(Long ticketOwnerId, Long ticketId, String ticketTitle, Status newStatus) {
        String statusLabel = getStatusLabel(newStatus);
        var event = NotificationEvent.forUser(
            ticketOwnerId,
            NotificationType.TICKET_STATUS_CHANGED,
            "Statut modifié",
            "Le ticket \"" + ticketTitle + "\" est maintenant : " + statusLabel,
            Map.of(
                KEY_TICKET_ID, ticketId.toString(),
                KEY_NEW_STATUS, newStatus.name()
            )
        );
        publish(event);
    }


    public void notifyAdminCommentAdded(Long ticketOwnerId, Long ticketId, String ticketTitle, String adminName) {
        var event = NotificationEvent.forUser(
            ticketOwnerId,
            NotificationType.TICKET_COMMENT_ADDED,
            "Nouveau commentaire",
            adminName + " a commenté votre ticket \"" + ticketTitle + "\"",
            Map.of(KEY_TICKET_ID, ticketId.toString())
        );
        publish(event);
    }

    public void notifyTicketResolved(Long ticketOwnerId, Long ticketId, String ticketTitle) {
        var event = NotificationEvent.forUser(
            ticketOwnerId,
            NotificationType.TICKET_STATUS_CHANGED,
            "Ticket résolu ✓",
            "Votre ticket \"" + ticketTitle + "\" a été résolu",
            Map.of(
                KEY_TICKET_ID, ticketId.toString(),
                KEY_NEW_STATUS, Status.RESOLVED.name()
            )
        );
        publish(event);
    }

    public void notifyTicketRejected(Long ticketOwnerId, Long ticketId, String ticketTitle) {
        var event = NotificationEvent.forUser(
            ticketOwnerId,
            NotificationType.TICKET_STATUS_CHANGED,
            "Ticket rejeté",
            "Votre ticket \"" + ticketTitle + "\" a été rejeté",
            Map.of(
                KEY_TICKET_ID, ticketId.toString(),
                KEY_NEW_STATUS, Status.REJECTED.name()
            )
        );
        publish(event);
    }

    private void publish(NotificationEvent event) {
        log.info("Publishing notification: type={}, targetUser={}, targetOrg={}, title={}", 
            event.type(), event.targetUserId(), event.organizationId(), event.title());
        eventPublisher.publishEvent(event);
    }

    private String getStatusLabel(Status status) {
        return switch (status) {
            case OPEN -> "Ouvert";
            case IN_PROGRESS -> "En cours";
            case RESOLVED -> "Résolu";
            case REJECTED -> "Rejeté";
            case CANCELLED -> "Annulé";
        };
    }
}
