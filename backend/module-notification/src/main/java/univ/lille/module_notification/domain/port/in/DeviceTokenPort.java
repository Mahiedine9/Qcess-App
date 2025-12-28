package univ.lille.module_notification.domain.port.in;

import java.util.List;

public interface DeviceTokenPort {
    void registerToken(Long userId, Long organizationId, String fcmToken);
    List<String> getTokensByUserId(Long userId);
    List<String> getTokensByOrganizationId(Long organizationId);
    List<Long> getUserIdsByOrganizationId(Long organizationId);
}
