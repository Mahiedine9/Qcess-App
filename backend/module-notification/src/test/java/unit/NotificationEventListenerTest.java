package unit;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import univ.lille.enums.NotificationType;
import univ.lille.events.NotificationEvent;
import univ.lille.module_notification.domain.port.in.PushNotificationServicePort;
import univ.lille.module_notification.infrastructure.adapter.event.NotificationEventListener;

@ExtendWith(MockitoExtension.class)
@DisplayName("NotificationEventListener Tests")
class NotificationEventListenerTest {

    @Mock
    private PushNotificationServicePort pushNotificationService;

    @InjectMocks
    private NotificationEventListener notificationEventListener;

    private Long testUserId;
    private Long testOrganizationId;

    @BeforeEach
    void setUp() {
        testUserId = 1L;
        testOrganizationId = 10L;
    }

    @Test
    @DisplayName("Should handle user-targeted notification event")
    void testHandleNotificationEvent_UserTarget() {
        // Arrange
        NotificationEvent event = NotificationEvent.forUser(
            testUserId,
            NotificationType.TICKET_STATUS_CHANGED,
            "Test Title",
            "Test Body",
            Map.of("key", "value")
        );

        // Act
        notificationEventListener.handleNotificationEvent(event);

        // Assert
        verify(pushNotificationService, times(1)).sendPushToUser(
            testUserId,
            "Test Title",
            "Test Body",
            "TICKET_STATUS_CHANGED",
            Map.of("key", "value")
        );
        verify(pushNotificationService, never()).sendToOrganization(anyLong(), anyString(), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("Should handle organization-targeted notification event")
    void testHandleNotificationEvent_OrganizationTarget() {
        // Arrange
        NotificationEvent event = NotificationEvent.forOrganization(
            testOrganizationId,
            NotificationType.TICKET_STATUS_CHANGED,
            "Org Title",
            "Org Body",
            Map.of()
        );

        // Act
        notificationEventListener.handleNotificationEvent(event);

        // Assert
        verify(pushNotificationService, times(1)).sendToOrganization(
            testOrganizationId,
            "Org Title",
            "Org Body",
            "TICKET_STATUS_CHANGED",
            Map.of()
        );
        verify(pushNotificationService, never()).sendPushToUser(anyLong(), anyString(), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("Should skip notification with no target")
    void testHandleNotificationEvent_NoTarget() {
        // Arrange
        NotificationEvent event = new NotificationEvent(
            NotificationType.BROADCAST,
            null,  // No user ID
            null,  // No organization ID
            "Title",
            "Body",
            Map.of()
        );

        // Act
        notificationEventListener.handleNotificationEvent(event);

        // Assert
        verify(pushNotificationService, never()).sendPushToUser(anyLong(), anyString(), anyString(), anyString(), any());
        verify(pushNotificationService, never()).sendToOrganization(anyLong(), anyString(), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("Should handle notification with null type gracefully")
    void testHandleNotificationEvent_NullType() {
        // Arrange
        NotificationEvent event = new NotificationEvent(
            null,  // Null type
            testUserId,
            null,
            "Title",
            "Body",
            Map.of()
        );

        // Act
        notificationEventListener.handleNotificationEvent(event);

        // Assert
        verify(pushNotificationService, times(1)).sendPushToUser(
            testUserId,
            "Title",
            "Body",
            "UNKNOWN",
            Map.of()
        );
    }
}
