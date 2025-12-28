package univ.lille.module_notification.domain.port.in;

import java.util.List;

import univ.lille.module_notification.application.dto.NotificationDto;

public interface NotificationPort {
    List<NotificationDto> getNotificationsByUserId(Long userId);
    
    List<NotificationDto> getUnreadNotificationsByUserId(Long userId);
    
    long countUnreadByUserId(Long userId);
    
    NotificationDto markAsRead(Long notificationId, Long userId);
    
    void markAllAsReadByUserId(Long userId);
}