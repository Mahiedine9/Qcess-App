package univ.lille.module_maintenance.controller;

import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import univ.lille.infrastructure.adapter.security.QcessUserPrincipal;
import univ.lille.module_maintenance.application.dto.AddAdminCommentRequest;
import univ.lille.module_maintenance.application.dto.AddCommentRequest;
import univ.lille.module_maintenance.application.dto.CreateTicketRequest;
import univ.lille.module_maintenance.application.dto.TicketDTO;
import univ.lille.module_maintenance.application.dto.UpdateTicketRequest;
import univ.lille.module_maintenance.application.dto.UpdateTicketStatusRequest;
import univ.lille.module_maintenance.domain.model.Priority;
import univ.lille.module_maintenance.domain.model.Status;
import univ.lille.module_maintenance.domain.model.Ticket;
import univ.lille.module_maintenance.domain.port.in.TicketServicePort;

import java.util.List;
import java.util.Objects;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

@RequestMapping("/api/maintenance/tickets")
@RestController
@RequiredArgsConstructor
public class TicketController {

    private final TicketServicePort ticketService;

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/me")
    public ResponseEntity<List<TicketDTO>> getCurrentUserTickets(
            @AuthenticationPrincipal QcessUserPrincipal principal,
            @RequestParam(value = "status", required = false) Status status,
            @RequestParam(value = "priority", required = false) Priority priority) {

        if (principal == null || principal.getId() == null) {
            return ResponseEntity.status(401).build();
        }

        List<Ticket> tickets = ticketService.getTicketsForUser(
                Objects.requireNonNull(principal.getId()), status, priority);
        List<TicketDTO> ticketDTOs = tickets.stream()
                .map(TicketDTO::from)
                .toList();

        return ResponseEntity.ok(ticketDTOs);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/organization")
    public ResponseEntity<List<TicketDTO>> getOrganizationTickets(
            @AuthenticationPrincipal QcessUserPrincipal principal,
            @RequestParam(value = "status", required = false) Status status,
            @RequestParam(value = "priority", required = false) Priority priority) {

        if (principal == null || principal.getOrganizationId() == null) {
            return ResponseEntity.status(401).build();
        }

        List<Ticket> tickets = ticketService.getTicketsForOrganization(
                Objects.requireNonNull(principal.getOrganizationId()), status, priority);
        List<TicketDTO> ticketDTOs = tickets.stream()
                .map(TicketDTO::from)
                .toList();

        return ResponseEntity.ok(ticketDTOs);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/users/{userId}")
    public ResponseEntity<List<TicketDTO>> getUserTickets(
            @PathVariable("userId") Long userId,
            @RequestParam(value = "status", required = false) Status status,
            @RequestParam(value = "priority", required = false) Priority priority) {
        List<Ticket> tickets = ticketService.getTicketsForUser(
                Objects.requireNonNull(userId), status, priority);
        List<TicketDTO> ticketDTOs = tickets.stream()
                .map(TicketDTO::from)
                .toList();

        return ResponseEntity.ok(ticketDTOs);
    }

    @PreAuthorize("hasAnyRole('USER','ADMIN')")
    @GetMapping("/{id}")
    public ResponseEntity<TicketDTO> getTicketById(
            @PathVariable("id") Long id,
            @AuthenticationPrincipal QcessUserPrincipal principal) {
        if (principal == null || principal.getId() == null) {
            return ResponseEntity.status(401).build();
        }

        Ticket ticket = ticketService.getTicketById(Objects.requireNonNull(id));

        boolean isAdmin = principal.getAuthorities() != null && principal.getAuthorities().stream()
                .anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()));

        if (!isAdmin && !ticket.belongsTo(principal.getId())) {
            return ResponseEntity.status(403).build();
        }
        if (isAdmin && (principal.getOrganizationId() == null || !ticket.belongsToOrganization(principal.getOrganizationId()))) {
            return ResponseEntity.status(403).build();
        }

        return ResponseEntity.ok(TicketDTO.from(ticket));
    }

    @PreAuthorize("hasRole('USER')")
    @PostMapping
    public ResponseEntity<TicketDTO> createTicket(
            @AuthenticationPrincipal QcessUserPrincipal principal,
            @Valid @RequestBody CreateTicketRequest request) {

        if (principal == null || principal.getId() == null || principal.getOrganizationId() == null) {
            return ResponseEntity.status(401).build();
        }

        Ticket createdTicket = ticketService.createTicket(
                request.toDomain(
                        principal.getId(),
                        principal.getOrganizationId(),
                        principal.getDisplayName()
                )
        );
        return ResponseEntity.status(201).body(TicketDTO.from(createdTicket));
    }

    @PreAuthorize("hasRole('USER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<TicketDTO> cancelTicket(
            @PathVariable("id") Long id,
            @AuthenticationPrincipal QcessUserPrincipal principal) {
        if (principal == null || principal.getId() == null) {
            return ResponseEntity.status(401).build();
        }

        Ticket cancelledTicket = ticketService.cancelTicket(Objects.requireNonNull(id), Objects.requireNonNull(principal.getId()));
        return ResponseEntity.ok(TicketDTO.from(cancelledTicket));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}/update-status")
    public ResponseEntity<TicketDTO> updateTicketStatus(@PathVariable("id") Long id,
                                                   @RequestBody @Valid UpdateTicketStatusRequest newStatusRequest) {
        Ticket updatedTicket = ticketService.updateStatus(Objects.requireNonNull(id), Objects.requireNonNull(newStatusRequest.newStatus()));

        return ResponseEntity.ok(TicketDTO.from(updatedTicket));
    }

    @PreAuthorize("hasRole('USER')")
    @PutMapping("/{id}")
    public ResponseEntity<TicketDTO> updateTicket(@PathVariable("id") Long id,
                                             @RequestBody @Valid UpdateTicketRequest ticketRequest) {
        Ticket updatedTicket = ticketService.updateTicket(
                Objects.requireNonNull(id),
                Objects.requireNonNull(ticketRequest.title()),
                ticketRequest.description()
        );
        return ResponseEntity.ok(TicketDTO.from(updatedTicket));
    }

    @PreAuthorize("hasRole('USER')")
    @PostMapping("/{id}/comments")
    public ResponseEntity<TicketDTO> addUserComment(
            @PathVariable("id") Long id,
            @RequestBody @Valid AddCommentRequest request,
            @AuthenticationPrincipal QcessUserPrincipal principal) {
        if (principal == null || principal.getId() == null) {
            return ResponseEntity.status(401).build();
        }

        Ticket updatedTicket = ticketService.addUserComment(
                Objects.requireNonNull(id),
                Objects.requireNonNull(request.content()),
                Objects.requireNonNull(principal.getId()),
                principal.getDisplayName()
        );

        return ResponseEntity.status(201).body(TicketDTO.from(updatedTicket));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{id}/admin-comments")
    public ResponseEntity<TicketDTO> addAdminComment(
            @PathVariable("id") Long id,
            @RequestBody @Valid AddAdminCommentRequest request,
            @AuthenticationPrincipal QcessUserPrincipal principal) {
        if (principal == null || principal.getId() == null) {
            return ResponseEntity.status(401).build();
        }

        Ticket updatedTicket = ticketService.addAdminCommentToThread(
                Objects.requireNonNull(id),
                Objects.requireNonNull(request.comment()),
                Objects.requireNonNull(principal.getId()),
                principal.getDisplayName()
        );

        return ResponseEntity.status(201).body(TicketDTO.from(updatedTicket));
    }
}