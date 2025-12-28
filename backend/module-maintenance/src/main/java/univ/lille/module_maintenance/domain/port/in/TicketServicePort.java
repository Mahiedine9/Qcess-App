package univ.lille.module_maintenance.domain.port.in;

import org.springframework.lang.NonNull;
import univ.lille.module_maintenance.domain.model.Priority;
import univ.lille.module_maintenance.domain.model.Status;
import univ.lille.module_maintenance.domain.model.Ticket;

import java.util.List;

public interface TicketServicePort {

    @NonNull
    Ticket createTicket(@NonNull Ticket ticket);

    @NonNull
    Ticket getTicketById(@NonNull Long ticketId);

    @NonNull
    List<Ticket> getTicketsForUser(@NonNull Long userId);

    @NonNull
    List<Ticket> getTicketsForUser(@NonNull Long userId, Status status, Priority priority);

    @NonNull
    List<Ticket> getTicketsForOrganization(@NonNull Long organizationId);

    @NonNull
    List<Ticket> getTicketsForOrganization(@NonNull Long organizationId, Status status, Priority priority);

    @NonNull
    Ticket updateStatus(@NonNull Long ticketId, @NonNull Status newStatus);

    @NonNull
    Ticket updateTicket(@NonNull Long ticketId, @NonNull String title, String description);

    @NonNull
    Ticket addUserComment(@NonNull Long ticketId, @NonNull String content, @NonNull Long authorUserId, String authorUserName);

    @NonNull
    Ticket addAdminCommentToThread(@NonNull Long ticketId, @NonNull String content, @NonNull Long authorUserId, String authorUserName);

    @NonNull
    Ticket cancelTicket(@NonNull Long ticketId, @NonNull Long userId);

    void deleteTicket(@NonNull Long ticketId);
}
