package univ.lille.module_notification.application.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import univ.lille.module_notification.domain.port.in.DeviceTokenPort;
import univ.lille.module_notification.domain.port.out.DeviceTokenRepositoryPort;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DeviceTokenService implements DeviceTokenPort {

    private final DeviceTokenRepositoryPort deviceTokenRepository;

    @Override
    public void registerToken(Long userId, Long organizationId, String fcmToken) {
        deviceTokenRepository.save(userId, organizationId, fcmToken);
    }

    @Override
    public List<String> getTokensByUserId(Long userId) {
        return deviceTokenRepository.getTokensByUserId(userId);
    }

    @Override
    public List<String> getTokensByOrganizationId(Long organizationId) {
        return deviceTokenRepository.getTokensByOrganizationId(organizationId);
    }

    @Override
    public List<Long> getUserIdsByOrganizationId(Long organizationId) {
        return deviceTokenRepository.getUserIdsByOrganizationId(organizationId);
    }
}
