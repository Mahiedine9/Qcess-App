package univ.lille.module_maintenance.domain.port.in;

import univ.lille.module_maintenance.domain.model.Status;

public interface NotificationPublisherPort {

	void notifyTicketStatusChanged(Long ticketOwnerId, Long ticketId, String ticketTitle, Status newStatus);

	void notifyAdminCommentAdded(Long ticketOwnerId, Long ticketId, String ticketTitle, String adminName);

	void notifyTicketResolved(Long ticketOwnerId, Long ticketId, String ticketTitle);

	void notifyTicketRejected(Long ticketOwnerId, Long ticketId, String ticketTitle);

}
