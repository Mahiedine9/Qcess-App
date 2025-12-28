package univ.lille.module_notification.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import univ.lille.application.service.AuthenticationService;
import univ.lille.module_notification.application.dto.NotificationDto;
import univ.lille.module_notification.domain.port.in.NotificationPort;

@Slf4j
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {
    private final NotificationPort notificationService;
    private final AuthenticationService authenticationService;

    @GetMapping
    public ResponseEntity<List<NotificationDto>> getMyNotifications(
            @RequestParam(name = "page", required = false, defaultValue = "0") int page,
            @RequestParam(name = "size", required = false, defaultValue = "20") int size) {
        Long userId = authenticationService.getCurrentUserId();
        log.info("Getting notifications for user {} page={} size={} ", userId, page, size);
        List<NotificationDto> notifications = notificationService.getNotificationsByUserId(userId);
        int from = Math.max(0, Math.min(page * size, notifications.size()));
        int to = Math.max(from, Math.min(from + size, notifications.size()));
        notifications = notifications.subList(from, to);
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/unread")
    public ResponseEntity<List<NotificationDto>> getMyUnreadNotifications(
            @RequestParam(name = "page", required = false, defaultValue = "0") int page,
            @RequestParam(name = "size", required = false, defaultValue = "20") int size) {
        Long userId = authenticationService.getCurrentUserId();
        log.info("Getting unread notifications for user {} page={} size={} ", userId, page, size);
        List<NotificationDto> notifications = notificationService.getUnreadNotificationsByUserId(userId);
        int from = Math.max(0, Math.min(page * size, notifications.size()));
        int to = Math.max(from, Math.min(from + size, notifications.size()));
        notifications = notifications.subList(from, to);
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/unread/count")
    public ResponseEntity<Long> countMyUnread() {
        Long userId = authenticationService.getCurrentUserId();
        long count = notificationService.countUnreadByUserId(userId);
        return ResponseEntity.ok(count);
    }

    @PutMapping("/{notificationId}/read")
    public ResponseEntity<NotificationDto> markAsRead(@PathVariable("notificationId") Long notificationId) {
        Long userId = authenticationService.getCurrentUserId();
        log.info("User {} marking notification {} as read", userId, notificationId);
        NotificationDto notification = notificationService.markAsRead(notificationId, userId);
        return ResponseEntity.ok(notification);
    }


    @PutMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead() {
        Long userId = authenticationService.getCurrentUserId();
        log.info("Marking all notifications as read for user {}", userId);
        notificationService.markAllAsReadByUserId(userId);
        return ResponseEntity.noContent().build();
    }
}