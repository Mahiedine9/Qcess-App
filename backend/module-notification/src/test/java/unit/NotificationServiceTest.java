package unit;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import univ.lille.module_notification.application.dto.NotificationDto;
import univ.lille.module_notification.application.service.NotificationService;
import univ.lille.module_notification.domain.model.Notification;
import univ.lille.module_notification.domain.port.out.NotificationRepositoryPort;
import univ.lille.module_notification.exception.ForbiddenException;
import univ.lille.module_notification.exception.NotFoundException;

@ExtendWith(MockitoExtension.class)
@DisplayName("NotificationService Tests")
class NotificationServiceTest {

    @Mock
    private NotificationRepositoryPort notificationRepository;

    @InjectMocks
    private NotificationService notificationService;

    private Notification testNotification;
    private Long testUserId;
    private Long testNotificationId;

    @BeforeEach
    void setUp() {
        testUserId = 1L;
        testNotificationId = 100L;
        testNotification = Notification.builder()
                .id(testNotificationId)
                .userId(testUserId)
                .title("Test Notification")
                .body("This is a test notification")
                .type("TEST")
                .read(false)
                .createdAt(LocalDateTime.now())
                .build();
    }

    @Test
    @DisplayName("Should get all notifications by user ID")
    void testGetNotificationsByUserId() {
        // Arrange
        List<Notification> notifications = List.of(testNotification);
        when(notificationRepository.findByUserId(testUserId)).thenReturn(notifications);

        // Act
        List<NotificationDto> result = notificationService.getNotificationsByUserId(testUserId);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("Test Notification", result.get(0).title());
        verify(notificationRepository, times(1)).findByUserId(testUserId);
    }

    @Test
    @DisplayName("Should get empty list when user has no notifications")
    void testGetNotificationsByUserId_Empty() {
        // Arrange
        when(notificationRepository.findByUserId(testUserId)).thenReturn(List.of());

        // Act
        List<NotificationDto> result = notificationService.getNotificationsByUserId(testUserId);

        // Assert
        assertNotNull(result);
        assertTrue(result.isEmpty());
        verify(notificationRepository, times(1)).findByUserId(testUserId);
    }

    @Test
    @DisplayName("Should get unread notifications by user ID")
    void testGetUnreadNotificationsByUserId() {
        // Arrange
        List<Notification> unreadNotifications = List.of(testNotification);
        when(notificationRepository.findUnreadByUserId(testUserId)).thenReturn(unreadNotifications);

        // Act
        List<NotificationDto> result = notificationService.getUnreadNotificationsByUserId(testUserId);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertFalse(result.get(0).read());
        verify(notificationRepository, times(1)).findUnreadByUserId(testUserId);
    }

    @Test
    @DisplayName("Should count unread notifications for user")
    void testCountUnreadByUserId() {
        // Arrange
        when(notificationRepository.countUnreadByUserId(testUserId)).thenReturn(3L);

        // Act
        long result = notificationService.countUnreadByUserId(testUserId);

        // Assert
        assertEquals(3L, result);
        verify(notificationRepository, times(1)).countUnreadByUserId(testUserId);
    }

    @Test
    @DisplayName("Should mark notification as read")
    void testMarkAsRead() {
        // Arrange
        Notification readNotification = Notification.builder()
                .id(testNotificationId)
                .userId(testUserId)
                .title("Test Notification")
                .body("Test Body")
                .type("TEST")
                .read(true)
                .createdAt(LocalDateTime.now())
                .readAt(LocalDateTime.now())
                .build();
        when(notificationRepository.findById(testNotificationId)).thenReturn(Optional.of(testNotification));
        when(notificationRepository.markAsRead(testNotificationId)).thenReturn(readNotification);

        // Act
        NotificationDto result = notificationService.markAsRead(testNotificationId, testUserId);

        // Assert
        assertNotNull(result);
        assertTrue(result.read());
        verify(notificationRepository, times(1)).findById(testNotificationId);
        verify(notificationRepository, times(1)).markAsRead(testNotificationId);
    }

    @Test
    @DisplayName("Should throw NotFoundException when notification not found")
    void testMarkAsRead_NotFound() {
        // Arrange
        when(notificationRepository.findById(testNotificationId)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(NotFoundException.class, () -> 
            notificationService.markAsRead(testNotificationId, testUserId)
        );
        verify(notificationRepository, times(1)).findById(testNotificationId);
        verify(notificationRepository, never()).markAsRead(anyLong());
    }

    @Test
    @DisplayName("Should throw ForbiddenException when user doesn't own notification")
    void testMarkAsRead_Forbidden() {
        // Arrange
        Long differentUserId = 999L;
        when(notificationRepository.findById(testNotificationId)).thenReturn(Optional.of(testNotification));

        // Act & Assert
        assertThrows(ForbiddenException.class, () -> 
            notificationService.markAsRead(testNotificationId, differentUserId)
        );
        verify(notificationRepository, times(1)).findById(testNotificationId);
        verify(notificationRepository, never()).markAsRead(anyLong());
    }

    @Test
    @DisplayName("Should mark all notifications as read for user")
    void testMarkAllAsReadByUserId() {
        // Arrange
        doNothing().when(notificationRepository).markAllAsReadByUserId(testUserId);

        // Act
        notificationService.markAllAsReadByUserId(testUserId);

        // Assert
        verify(notificationRepository, times(1)).markAllAsReadByUserId(testUserId);
    }
}
