package univ.lille.module_notification.application.service;

import java.util.List;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import univ.lille.module_notification.application.dto.NotificationDto;
import univ.lille.module_notification.domain.port.in.NotificationPort;
import univ.lille.module_notification.domain.port.out.NotificationRepositoryPort;
import univ.lille.module_notification.exception.ForbiddenException;
import univ.lille.module_notification.exception.NotFoundException;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService implements NotificationPort {

    private final NotificationRepositoryPort notificationRepository;

    @Override
    public List<NotificationDto> getNotificationsByUserId(Long userId) {
        return notificationRepository.findByUserId(userId)
                .stream()
                .map(NotificationDto::from)
                .toList();
    }

    @Override
    public List<NotificationDto> getUnreadNotificationsByUserId(Long userId) {
        return notificationRepository.findUnreadByUserId(userId)
                .stream()
                .map(NotificationDto::from)
                .toList();
    }

    @Override
    public long countUnreadByUserId(Long userId) {
        return notificationRepository.countUnreadByUserId(userId);
    }

    @Override
    public NotificationDto markAsRead(Long notificationId, Long userId) {
        var notifOpt = notificationRepository.findById(notificationId);
        if (notifOpt.isEmpty()) {
            throw new NotFoundException("Notification not found: " + notificationId);
        }
        var notif = notifOpt.get();
        if (!notif.getUserId().equals(userId)) {
            throw new ForbiddenException("Forbidden: notification does not belong to user " + userId);
        }
        return NotificationDto.from(notificationRepository.markAsRead(notificationId));
    }

    @Override
    public void markAllAsReadByUserId(Long userId) {
        notificationRepository.markAllAsReadByUserId(userId);
        log.info("All notifications marked as read for user {}", userId);
    }
}