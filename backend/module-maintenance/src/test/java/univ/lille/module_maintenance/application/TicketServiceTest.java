package univ.lille.module_maintenance.application;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import univ.lille.domain.port.out.NotificationPort;
import univ.lille.module_maintenance.application.service.NotificationPublisher;
import univ.lille.module_maintenance.application.service.TicketService;
import univ.lille.module_maintenance.domain.exception.CommentException;
import univ.lille.module_maintenance.domain.exception.InvalidTicketException;
import univ.lille.module_maintenance.domain.exception.TicketNotFoundException;
import univ.lille.module_maintenance.domain.exception.UnauthorizedAccessException;
import univ.lille.module_maintenance.domain.model.Comment;
import univ.lille.module_maintenance.domain.model.CommentType;
import univ.lille.module_maintenance.domain.model.Priority;
import univ.lille.module_maintenance.domain.model.Status;
import univ.lille.module_maintenance.domain.model.Ticket;
import univ.lille.module_maintenance.domain.port.out.TicketRepositoryPort;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("null")
class TicketServiceTest {

    @Mock
    private TicketRepositoryPort ticketRepository;

    @Mock
    private NotificationPublisher notificationPublisher;

    @Mock
    private NotificationPort notificationPort;

    @InjectMocks
    private TicketService service;

    private Ticket baseTicket;

    @BeforeEach
    void setup() {
        baseTicket = Ticket.builder()
                .id(10L)
                .title("Initial Title")
                .description("Initial Description")
                .priority(Priority.HIGH)
                .status(Status.OPEN)
                .createdByUserId(5L)
                .createdByUserName("user5")
                .organizationId(3L)
                .createdAt(LocalDateTime.now().minusMinutes(5))
                .updatedAt(LocalDateTime.now().minusMinutes(5))
                .build();

        lenient().when(ticketRepository.save(any(Ticket.class))).thenAnswer(i -> i.getArguments()[0]);
    }

    @Test
    @DisplayName("createTicket sets OPEN when status is null")
    void createTicket_setsOpenIfNull() {
        Ticket t = Ticket.builder()
                .title("T")
                .priority(Priority.NORMAL)
                .createdByUserId(1L)
                .organizationId(2L)
                .build();

        service.createTicket(t);

        assertEquals(Status.OPEN, t.getStatus());
        verify(ticketRepository).save(t);
    }

    @Test
    @DisplayName("getTicketById returns ticket when found")
    void getTicketById_found() {
        when(ticketRepository.findById(10L)).thenReturn(Optional.of(baseTicket));
        Ticket result = service.getTicketById(10L);
        assertEquals(baseTicket, result);
    }

    @Test
    @DisplayName("getTicketById throws when not found")
    void getTicketById_notFound() {
        when(ticketRepository.findById(11L)).thenReturn(Optional.empty());
        assertThrows(TicketNotFoundException.class, () -> service.getTicketById(11L));
    }

    @Test
    @DisplayName("getTicketsForUser delegates to repository")
    void getTicketsForUser() {
        when(ticketRepository.findByUserId(5L)).thenReturn(List.of(baseTicket));
        List<Ticket> list = service.getTicketsForUser(5L);
        assertEquals(1, list.size());
        verify(ticketRepository).findByUserId(5L);
    }

    @Test
    @DisplayName("getTicketsForOrganization delegates to repository")
    void getTicketsForOrganization() {
        when(ticketRepository.findByOrganizationId(3L)).thenReturn(List.of(baseTicket));
        List<Ticket> list = service.getTicketsForOrganization(3L);
        assertEquals(1, list.size());
        verify(ticketRepository).findByOrganizationId(3L);
    }

    @Nested
    class UpdateStatusTests {
        @Test
        @DisplayName("updateStatus succeeds for valid transition")
        void updateStatus_validTransition() {
            when(ticketRepository.findById(10L)).thenReturn(Optional.of(baseTicket));
            when(ticketRepository.save(baseTicket)).thenReturn(baseTicket);
            service.updateStatus(10L, Status.IN_PROGRESS);
            assertEquals(Status.IN_PROGRESS, baseTicket.getStatus());
            verify(ticketRepository).save(baseTicket);
        }

        @Test
        @DisplayName("updateStatus throws InvalidTicketException for invalid transition from terminal state")
        void updateStatus_invalidTransition() {
            baseTicket.setStatus(Status.CANCELLED);
            when(ticketRepository.findById(10L)).thenReturn(Optional.of(baseTicket));
            assertThrows(InvalidTicketException.class, () -> service.updateStatus(10L, Status.OPEN));
        }

        @Test
        @DisplayName("updateStatus ticket not found throws")
        void updateStatus_ticketNotFound() {
            when(ticketRepository.findById(99L)).thenReturn(Optional.empty());
            assertThrows(TicketNotFoundException.class, () -> service.updateStatus(99L, Status.OPEN));
        }
    }

    @Nested
    class UpdateTicketTests {
        @Test
        @DisplayName("updateTicket updates title & description and saves")
        void updateTicket_success() {
            when(ticketRepository.findById(10L)).thenReturn(Optional.of(baseTicket));
            service.updateTicket(10L, "New Title", "New Description");
            assertEquals("New Title", baseTicket.getTitle());
            assertEquals("New Description", baseTicket.getDescription());
            verify(ticketRepository).save(baseTicket);
        }

        @Test
        @DisplayName("updateTicket blank title throws InvalidTicketException")
        void updateTicket_blankTitle() {
            assertThrows(InvalidTicketException.class, () -> service.updateTicket(10L, "   ", "Desc"));
        }

        @Test
        @DisplayName("updateTicket not found throws")
        void updateTicket_notFound() {
            when(ticketRepository.findById(77L)).thenReturn(Optional.empty());
            assertThrows(TicketNotFoundException.class, () -> service.updateTicket(77L, "T", "D"));
        }
    }

    @Nested
    class CommentTests {
        @Test
        @DisplayName("addUserComment blank content throws CommentException")
        void addUserComment_blank() {
            assertThrows(CommentException.class, () -> service.addUserComment(10L, "   ", 5L, "User5"));
            verify(ticketRepository, never()).findById(anyLong());
        }

        @Test
        @DisplayName("addUserComment unauthorized when not owner")
        void addUserComment_notOwner() {
            when(ticketRepository.findById(10L)).thenReturn(Optional.of(baseTicket));
            assertThrows(UnauthorizedAccessException.class, () -> service.addUserComment(10L, "Hello", 999L, "User999"));
        }

        @Test
        @DisplayName("addUserComment success adds comment and saves")
        void addUserComment_success() {
            when(ticketRepository.findById(10L)).thenReturn(Optional.of(baseTicket));
            service.addUserComment(10L, "Content", 5L, "User5");
            assertEquals(1, baseTicket.getComments().size());
            Comment c = baseTicket.getComments().get(0);
            assertEquals("Content", c.getContent());
            assertEquals(CommentType.USER, c.getType());
            verify(ticketRepository).save(baseTicket);
        }

        @Test
        @DisplayName("addAdminComment success adds admin comment and saves")
        void addAdminComment_success() {
            when(ticketRepository.findById(10L)).thenReturn(Optional.of(baseTicket));
            when(ticketRepository.save(baseTicket)).thenReturn(baseTicket);
            service.addAdminCommentToThread(10L, "Admin Response", 50L, "AdminUser");
            assertEquals(1, baseTicket.getComments().size());
            Comment c = baseTicket.getComments().get(0);
            assertEquals(CommentType.ADMIN, c.getType());
            assertEquals("Admin Response", c.getContent());
            verify(ticketRepository).save(baseTicket);
        }

        @Test
        @DisplayName("addAdminComment ticket not found throws")
        void addAdminComment_notFound() {
            when(ticketRepository.findById(999L)).thenReturn(Optional.empty());
            assertThrows(TicketNotFoundException.class, () -> service.addAdminCommentToThread(999L, "X", 1L, "AdminUser"));
        }
    }

    @Nested
    class CancelTests {
        @Test
        @DisplayName("cancelTicket not found throws")
        void cancel_notFound() {
            when(ticketRepository.findById(10L)).thenReturn(Optional.empty());
            assertThrows(TicketNotFoundException.class, () -> service.cancelTicket(10L, 5L));
        }

        @Test
        @DisplayName("cancelTicket unauthorized when not owner")
        void cancel_notOwner() {
            baseTicket.setCreatedByUserId(5L);
            when(ticketRepository.findById(10L)).thenReturn(Optional.of(baseTicket));
            assertThrows(UnauthorizedAccessException.class, () -> service.cancelTicket(10L, 7L));
        }

        @Test
        @DisplayName("cancelTicket invalid when status not cancellable")
        void cancel_invalidStatus() {
            baseTicket.setStatus(Status.RESOLVED);
            when(ticketRepository.findById(10L)).thenReturn(Optional.of(baseTicket));
            assertThrows(InvalidTicketException.class, () -> service.cancelTicket(10L, 5L));
        }

        @Test
        @DisplayName("cancelTicket success sets CANCELLED and saves")
        void cancel_success() {
            baseTicket.setStatus(Status.OPEN);
            when(ticketRepository.findById(10L)).thenReturn(Optional.of(baseTicket));
            service.cancelTicket(10L, 5L);
            assertEquals(Status.CANCELLED, baseTicket.getStatus());
            verify(ticketRepository).save(baseTicket);
        }
    }

    @Test
    @DisplayName("deleteTicket delegates to repository")
    void deleteTicket() {
        service.deleteTicket(55L);
        verify(ticketRepository).deleteById(55L);
    }
}
