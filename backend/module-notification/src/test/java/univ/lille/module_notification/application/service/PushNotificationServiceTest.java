package univ.lille.module_notification.application.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import univ.lille.module_notification.domain.model.Notification;
import univ.lille.module_notification.domain.port.in.DeviceTokenPort;
import univ.lille.module_notification.domain.port.out.NotificationRepositoryPort;
import univ.lille.module_notification.domain.port.out.PushNotificationRepositoryPort;

@ExtendWith(MockitoExtension.class)
@DisplayName("PushNotificationService Tests")
class PushNotificationServiceTest {

    @Mock
    private PushNotificationRepositoryPort pushNotificationRepositoryPort;
    @Mock
    private DeviceTokenPort deviceTokenService;

    @Mock
    private NotificationRepositoryPort notificationRepository;

    @InjectMocks
    private PushNotificationService pushNotificationService;

    private Long testUserId;
    private Long testTicketId;
    private String testTicketTitle;
    private String testFcmToken;

    @BeforeEach
    void setUp() {
        testUserId = 1L;
        testTicketId = 100L;
        testTicketTitle = "Test Ticket";
        testFcmToken = "test_fcm_token_12345";
    }

    @Test
    @DisplayName("Should send push to single token")
    void testSendToToken() {
        // Arrange
        String title = "Test Title";
        String body = "Test Body";
        Map<String, String> data = Map.of("key", "value");

        // Act
        pushNotificationService.sendToToken(testFcmToken, title, body, data);

        // Assert
        verify(pushNotificationRepositoryPort, times(1)).sendPushToToken(testFcmToken, title, body, data);
    }

    @Test
    @DisplayName("Should send push notification to user with multiple devices")
    void testSendPushToUser_MultipleDevices() {
        // Arrange
        List<String> tokens = List.of("token1", "token2", "token3");
        when(deviceTokenService.getTokensByUserId(testUserId)).thenReturn(tokens);
        when(notificationRepository.save(any(Notification.class))).thenAnswer(inv -> inv.getArgument(0));

        // Act
        pushNotificationService.sendPushToUser(testUserId, "Title", "Body", "TEST", Map.of());

        // Assert
        verify(notificationRepository, times(1)).save(any(Notification.class));
        verify(pushNotificationRepositoryPort, times(3)).sendPushToToken(anyString(), anyString(), anyString(), any());
        verify(pushNotificationRepositoryPort).sendPushToToken("token1", "Title", "Body", Map.of());
        verify(pushNotificationRepositoryPort).sendPushToToken("token2", "Title", "Body", Map.of());
        verify(pushNotificationRepositoryPort).sendPushToToken("token3", "Title", "Body", Map.of());
    }

    @Test
    @DisplayName("Should store notification and not send if no tokens")
    void testSendPushToUser_NoTokens() {
        // Arrange
        when(deviceTokenService.getTokensByUserId(testUserId)).thenReturn(List.of());
        when(notificationRepository.save(any(Notification.class))).thenAnswer(inv -> inv.getArgument(0));

        // Act
        pushNotificationService.sendPushToUser(testUserId, "Title", "Body", "TEST", Map.of());

        // Assert
        verify(notificationRepository, times(1)).save(any(Notification.class));
        verify(pushNotificationRepositoryPort, never()).sendPushToToken(anyString(), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("Should notify ticket status changed")
    void testNotifyTicketStatusChanged() {
        // Arrange
        List<String> tokens = List.of(testFcmToken);
        when(deviceTokenService.getTokensByUserId(testUserId)).thenReturn(tokens);
        when(notificationRepository.save(any(Notification.class))).thenAnswer(inv -> {
            Notification notif = inv.getArgument(0);
            // Simulate @CreationTimestamp behavior
            if (notif.getCreatedAt() == null) {
                notif.setCreatedAt(LocalDateTime.now());
            }
            return notif;
        });

        // Act
        pushNotificationService.sendPushToUser(
            testUserId,
            "Statut modifié",
            "Le ticket \"" + testTicketTitle + "\" est maintenant : En cours",
            "TICKET_STATUS_CHANGED",
            Map.of("ticketId", testTicketId.toString(), "newStatus", "IN_PROGRESS")
        );

        // Assert
        ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
        verify(notificationRepository).save(notificationCaptor.capture());
        
        Notification savedNotification = notificationCaptor.getValue();
        assertEquals(testUserId, savedNotification.getUserId());
        assertEquals("TICKET_STATUS_CHANGED", savedNotification.getType());
        assertFalse(savedNotification.isRead());
        assertNotNull(savedNotification.getCreatedAt());
    }

    @Test
    @DisplayName("Should notify ticket resolved")
    void testNotifyTicketResolved() {
        // Arrange
        List<String> tokens = List.of(testFcmToken);
        when(deviceTokenService.getTokensByUserId(testUserId)).thenReturn(tokens);
        when(notificationRepository.save(any(Notification.class))).thenAnswer(inv -> inv.getArgument(0));

        // Act
        pushNotificationService.sendPushToUser(
            testUserId,
            "Ticket résolu ✓",
            "Votre ticket \"" + testTicketTitle + "\" a été résolu",
            "TICKET_STATUS_CHANGED",
            Map.of("ticketId", testTicketId.toString())
        );

        // Assert
        ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
        verify(notificationRepository).save(notificationCaptor.capture());
        
        Notification savedNotification = notificationCaptor.getValue();
        assertEquals("Ticket résolu ✓", savedNotification.getTitle());
        assertTrue(savedNotification.getBody().contains("résolu"));
    }

    @Test
    @DisplayName("Should broadcast notification to organization")
    void testSendToOrganization() {
        // Arrange
        Long organizationId = 10L;
        List<Long> userIds = List.of(1L, 2L, 3L);
        List<String> tokens = List.of("org_token1", "org_token2", "org_token3");
        
        when(deviceTokenService.getUserIdsByOrganizationId(organizationId)).thenReturn(userIds);
        when(deviceTokenService.getTokensByOrganizationId(organizationId)).thenReturn(tokens);
        when(notificationRepository.save(any(Notification.class))).thenAnswer(inv -> inv.getArgument(0));

        // Act
        pushNotificationService.sendToOrganization(organizationId, "Broadcast Title", "Broadcast Body", "SYSTEM", Map.of());

        // Assert
        verify(notificationRepository, times(3)).save(any(Notification.class));
        verify(pushNotificationRepositoryPort, times(3)).sendPushToToken(anyString(), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("Should handle empty organization gracefully")
    void testSendToOrganization_Empty() {
        // Arrange
        Long organizationId = 10L;
        when(deviceTokenService.getUserIdsByOrganizationId(organizationId)).thenReturn(List.of());
        when(deviceTokenService.getTokensByOrganizationId(organizationId)).thenReturn(List.of());

        // Act
        pushNotificationService.sendToOrganization(organizationId, "Title", "Body", "SYSTEM", Map.of());

        // Assert
        verify(notificationRepository, never()).save(any(Notification.class));
        verify(pushNotificationRepositoryPort, never()).sendPushToToken(anyString(), anyString(), anyString(), any());
    }
}
