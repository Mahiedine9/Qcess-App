package univ.lille.module_maintenance.application.service;

import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import univ.lille.module_maintenance.domain.exception.CommentException;
import univ.lille.module_maintenance.domain.exception.InvalidTicketException;
import univ.lille.module_maintenance.domain.exception.TicketNotFoundException;
import univ.lille.module_maintenance.domain.exception.UnauthorizedAccessException;
import univ.lille.module_maintenance.domain.model.Comment;
import univ.lille.module_maintenance.domain.model.CommentType;
import univ.lille.module_maintenance.domain.model.Priority;
import univ.lille.module_maintenance.domain.model.Status;
import univ.lille.module_maintenance.domain.model.Ticket;
import univ.lille.module_maintenance.domain.port.in.NotificationPublisherPort;
import univ.lille.module_maintenance.domain.port.in.TicketServicePort;
import univ.lille.module_maintenance.domain.port.out.TicketRepositoryPort;
import univ.lille.domain.port.in.UserPort;
import univ.lille.domain.port.out.NotificationPort;
import univ.lille.dto.auth.user.UserDTO;
import univ.lille.module_maintenance.application.dto.TicketDTO;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TicketService implements TicketServicePort {

    private final TicketRepositoryPort ticketRepository;
    private final NotificationPublisherPort notificationPublisher;
    private final UserPort userPort;
    private final NotificationPort notificationPort;

    @Transactional
    @NonNull
    public Ticket createTicket(@NonNull Ticket ticket) {
        if (ticket.getStatus() == null) {
            ticket.setStatus(Status.OPEN);
        }
        if (ticket.getCreatedByUserName() == null) {
            enrichTicketsWithUserNames(List.of(ticket), ticket.getOrganizationId());
        }
        Ticket savedTicket = ticketRepository.save(ticket);
        
        TicketDTO ticketDTO = TicketDTO.from(savedTicket);
        notificationPort.notifyResourceUpdate(
            savedTicket.getOrganizationId(),
            "TICKET",
            savedTicket.getId(),
            convertTicketDTOToMap(ticketDTO)
        );
        
        return savedTicket;
    }

    @NonNull
    public Ticket getTicketById(@NonNull Long ticketId) {
        Ticket ticket = Objects.requireNonNull(
            ticketRepository.findById(ticketId)
                .orElseThrow(() -> new TicketNotFoundException(ticketId))
        );

        if (ticket.getCreatedByUserName() == null || hasMissingCommentAuthors(ticket)) {
            enrichTicketsWithUserNames(List.of(ticket), ticket.getOrganizationId());
        }

        if (ticket.getComments() != null) {
            ticket.getComments().sort(Comparator.comparing(Comment::getCreatedAt));
        }

        return ticket;
    }

    private boolean hasMissingCommentAuthors(Ticket ticket) {
        if (ticket.getComments() == null) return false;
        return ticket.getComments().stream().anyMatch(c -> c.getAuthorUserName() == null);
    }

    @NonNull
    public List<Ticket> getTicketsForUser(@NonNull Long userId) {
        List<Ticket> tickets = ticketRepository.findByUserId(userId);
        if (!tickets.isEmpty()) {
            enrichTicketsWithUserNames(tickets, tickets.get(0).getOrganizationId());
        }
        return tickets;
    }

    @NonNull
    public List<Ticket> getTicketsForUser(@NonNull Long userId, Status status, Priority priority) {
        List<Ticket> base = ticketRepository.findByUserId(userId);
        List<Ticket> filtered = Objects.requireNonNull(applyFilters(base, status, priority));
        if (!filtered.isEmpty()) {
            enrichTicketsWithUserNames(filtered, filtered.get(0).getOrganizationId());
        }
        return filtered;
    }

    @NonNull
    public List<Ticket> getTicketsForOrganization(@NonNull Long organizationId) {
        List<Ticket> tickets = ticketRepository.findByOrganizationId(organizationId);
        enrichTicketsWithUserNames(tickets, organizationId);
        return tickets;
    }

    @NonNull
    public List<Ticket> getTicketsForOrganization(@NonNull Long organizationId, Status status, Priority priority) {
        List<Ticket> base = ticketRepository.findByOrganizationId(organizationId);
        List<Ticket> filtered = Objects.requireNonNull(applyFilters(base, status, priority));
        enrichTicketsWithUserNames(filtered, organizationId);
        return filtered;
    }

    private void enrichTicketsWithUserNames(List<Ticket> tickets, Long organizationId) {
        boolean hasMissingNames = tickets.stream().anyMatch(t -> t.getCreatedByUserName() == null);
        boolean hasMissingCommentAuthors = tickets.stream()
            .filter(t -> t.getComments() != null)
            .flatMap(t -> t.getComments().stream())
            .anyMatch(c -> c.getAuthorUserName() == null);

        if (!hasMissingNames && !hasMissingCommentAuthors) return;

        try {
            List<UserDTO> users = userPort.getUsersByOrganizationId(organizationId);
            Map<Long, String> userNames = users.stream()
                .collect(Collectors.toMap(UserDTO::getId, UserDTO::getDisplayName));

            tickets.forEach(t -> {
                if (t.getCreatedByUserName() == null) {
                    t.setCreatedByUserName(userNames.get(t.getCreatedByUserId()));
                }
                if (t.getComments() != null) {
                    t.getComments().forEach(c -> {
                        if (c.getAuthorUserName() == null) {
                            c.setAuthorUserName(userNames.get(c.getAuthorUserId()));
                        }
                    });
                }
            });
        } catch (Exception e) {
            System.err.println("Failed to fetch users for ticket enrichment: " + e.getMessage());
        }
    }

    @Transactional
    @NonNull
    public Ticket updateStatus(@NonNull Long ticketId, @NonNull Status newStatus) {
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new TicketNotFoundException(ticketId));

        Status oldStatus = ticket.getStatus();
        
        try {
            ticket.updateStatus(newStatus);
        } catch (IllegalStateException ex) {
            throw InvalidTicketException.invalidTransition(
                    oldStatus != null ? oldStatus.name() : "<null>",
                    newStatus.name()
            );
        }

        Ticket savedTicket = ticketRepository.save(ticket);
        Long ownerId = savedTicket.getCreatedByUserId();
        if (ownerId != null) {
            if (newStatus == Status.RESOLVED) {
                notificationPublisher.notifyTicketResolved(
                    ownerId,
                    ticketId,
                    savedTicket.getTitle()
                );
            } else if (newStatus == Status.REJECTED) {
                notificationPublisher.notifyTicketRejected(
                    ownerId,
                    ticketId,
                    savedTicket.getTitle()
                );
            } else {
                notificationPublisher.notifyTicketStatusChanged(
                    ownerId,
                    ticketId,
                    savedTicket.getTitle(),
                    newStatus
                );
            }
        }

        enrichTicketsWithUserNames(List.of(savedTicket), savedTicket.getOrganizationId());
        
        // Notification SSE pour le changement de statut
        TicketDTO ticketDTO = TicketDTO.from(savedTicket);
        notificationPort.notifyResourceUpdate(
            savedTicket.getOrganizationId(),
            "TICKET",
            savedTicket.getId(),
            convertTicketDTOToMap(ticketDTO)
        );
        
        return savedTicket;
    }

    @Transactional
    @NonNull
    public Ticket updateTicket(@NonNull Long ticketId, @NonNull String title, String description) {
        if (title.isBlank()) {
            throw InvalidTicketException.missingTitle();
        }
        if (title.length() > 200) {
            throw InvalidTicketException.fieldTooLong("title", 200);
        }
        if (description != null && description.length() > 5000) {
            throw InvalidTicketException.fieldTooLong("description", 5000);
        }

        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new TicketNotFoundException(ticketId));

        ticket.setTitle(title);
        ticket.setDescription(description);
        ticket.setUpdatedAt(LocalDateTime.now());

        Ticket savedTicket = ticketRepository.save(ticket);
        enrichTicketsWithUserNames(List.of(savedTicket), savedTicket.getOrganizationId());
        return savedTicket;
    }

    @Transactional
    @NonNull
    public Ticket addUserComment(@NonNull Long ticketId, @NonNull String content, @NonNull Long authorUserId, String authorUserName) {
        if (content.isBlank()) {
            throw CommentException.emptyContent();
        }
        if (content.length() > 2000) {
            throw CommentException.contentTooLong(2000);
        }

        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new TicketNotFoundException(ticketId));

        if (ticket.getStatus() == Status.CANCELLED) {
            throw CommentException.cannotCommentCancelled();
        }

        if (!ticket.belongsTo(authorUserId)) {
            throw UnauthorizedAccessException.cannotCommentTicket(authorUserId, ticketId);
        }

        Comment comment = Comment.builder()
                .content(content)
                .authorUserId(authorUserId)
                .authorUserName(authorUserName)
                .type(CommentType.USER)
                .createdAt(LocalDateTime.now())
                .build();

        ticket.addComment(comment);
        ticket.setUpdatedAt(LocalDateTime.now());
        
        Ticket savedTicket = ticketRepository.save(ticket);
        enrichTicketsWithUserNames(List.of(savedTicket), savedTicket.getOrganizationId());
        if (savedTicket.getComments() != null) {
            savedTicket.getComments().sort(Comparator.comparing(Comment::getCreatedAt));
        }
        
        // Notification SSE pour le nouveau commentaire utilisateur
        TicketDTO ticketDTO = TicketDTO.from(savedTicket);
        notificationPort.notifyResourceUpdate(
            savedTicket.getOrganizationId(),
            "TICKET",
            savedTicket.getId(),
            convertTicketDTOToMap(ticketDTO)
        );
        
        return savedTicket;
    }

    @Transactional
    @NonNull
    public Ticket addAdminCommentToThread(@NonNull Long ticketId, @NonNull String content, @NonNull Long authorUserId, String authorUserName) {
        if (content.isBlank()) {
            throw CommentException.emptyContent();
        }
        if (content.length() > 2000) {
            throw CommentException.contentTooLong(2000);
        }

        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new TicketNotFoundException(ticketId));

        if (ticket.getStatus() == Status.CANCELLED) {
            throw CommentException.cannotCommentCancelled();
        }

        Comment comment = Comment.builder()
                .content(content)
                .authorUserId(authorUserId)
                .authorUserName(authorUserName)
                .type(CommentType.ADMIN)
                .createdAt(LocalDateTime.now())
                .build();

        ticket.addComment(comment);
        ticket.setUpdatedAt(LocalDateTime.now());
        
        Ticket savedTicket = ticketRepository.save(ticket);
        
        Long ownerId = savedTicket.getCreatedByUserId();
        if (ownerId != null && !ownerId.equals(authorUserId)) {
            notificationPublisher.notifyAdminCommentAdded(
                ownerId, 
                ticketId, 
                savedTicket.getTitle(), 
                authorUserName
            );
        }

        enrichTicketsWithUserNames(List.of(savedTicket), savedTicket.getOrganizationId());
        if (savedTicket.getComments() != null) {
            savedTicket.getComments().sort(Comparator.comparing(Comment::getCreatedAt));
        }
        
        // Notification SSE pour le nouveau commentaire admin
        TicketDTO ticketDTO = TicketDTO.from(savedTicket);
        notificationPort.notifyResourceUpdate(
            savedTicket.getOrganizationId(),
            "TICKET",
            savedTicket.getId(),
            convertTicketDTOToMap(ticketDTO)
        );
        
        return savedTicket;
    }
    
    // Méthode helper pour convertir TicketDTO en Map pour SSE
    private Map<String, Object> convertTicketDTOToMap(TicketDTO dto) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", dto.id());
        map.put("title", dto.title());
        map.put("description", dto.description());
        map.put("status", dto.status());
        map.put("priority", dto.priority());
        map.put("priorityColor", dto.priorityColor());
        map.put("createdByUserId", dto.createdByUserId());
        map.put("createdByUserName", dto.createdByUserName());
        map.put("organizationId", dto.organizationId());
        map.put("createdAt", dto.createdAt() != null ? dto.createdAt().toString() : null);
        map.put("updatedAt", dto.updatedAt() != null ? dto.updatedAt().toString() : null);
        
        // Inclure les commentaires complets pour la synchronisation
        if (dto.comments() != null) {
            List<Map<String, Object>> commentsList = dto.comments().stream()
                .map(comment -> {
                    Map<String, Object> commentMap = new HashMap<>();
                    commentMap.put("id", comment.getId());
                    commentMap.put("content", comment.getContent());
                    commentMap.put("type", comment.getType());
                    commentMap.put("authorUserId", comment.getAuthorUserId());
                    commentMap.put("authorUserName", comment.getAuthorUserName());
                    commentMap.put("createdAt", comment.getCreatedAt() != null ? comment.getCreatedAt().toString() : null);
                    return commentMap;
                })
                .collect(Collectors.toList());
            map.put("comments", commentsList);
        }
        
        return map;
    }

    @Transactional
    @NonNull
    public Ticket cancelTicket(@NonNull Long ticketId, @NonNull Long userId) {
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new TicketNotFoundException(ticketId));
		
        if (!ticket.belongsTo(userId)) {
            throw UnauthorizedAccessException.cannotCancelTicket(userId, ticketId);
        }
		
        Status currentStatus = ticket.getStatus();
        if (currentStatus == null || !currentStatus.isCancellable()) {
            throw InvalidTicketException.invalidTransition(
                    currentStatus != null ? currentStatus.name() : "<null>",
                    Status.CANCELLED.name()
            );
        }
		
        ticket.updateStatus(Status.CANCELLED);
        Ticket savedTicket = ticketRepository.save(ticket);
        enrichTicketsWithUserNames(List.of(savedTicket), savedTicket.getOrganizationId());
        return savedTicket;
    }

    @Transactional
    public void deleteTicket(@NonNull Long ticketId) {
        ticketRepository.deleteById(ticketId);
    }

    private List<Ticket> applyFilters(List<Ticket> tickets, Status status, univ.lille.module_maintenance.domain.model.Priority priority) {
        return tickets.stream()
            .filter(t -> status == null || status.equals(t.getStatus()))
            .filter(t -> priority == null || priority.equals(t.getPriority()))
            .toList();
    }
}