package univ.lille.application.usecase;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import univ.lille.domain.exception.UserNotFoundException;
import univ.lille.domain.exception.ZoneNotFoundException;
import univ.lille.domain.model.AccessLog;
import univ.lille.domain.model.User;
import univ.lille.domain.model.Zone;
import univ.lille.domain.port.in.AccessControlPort;
import univ.lille.domain.port.out.AccessLogNotificationPort;
import univ.lille.domain.port.out.AccessLogRepository;
import univ.lille.domain.port.out.NotificationPort;
import univ.lille.domain.port.out.UserRepository;
import univ.lille.domain.port.out.ZoneRepository;
import univ.lille.dto.access.AccessLogResponseDTO;
import univ.lille.dto.access.AccessResponseDTO;
import univ.lille.enums.ZoneStatus;
import java.util.Map;

@Service 
@RequiredArgsConstructor
public class AccessControlUseCase implements AccessControlPort {

    private final ZoneRepository zoneRepository ; 
    private final UserRepository userRepository ; 
    private final AccessLogRepository accessLogRepository ; 
    private final NotificationPort notificationPort; 
    @Override
    @Transactional
    public AccessResponseDTO validateAccess(Long userId, Long zoneId) {

        User user = userRepository.findById(userId).orElseThrow(()-> 
        new UserNotFoundException("User Not found ")) ; 

        Zone zone = zoneRepository.findById(zoneId).orElseThrow(() ->
                new ZoneNotFoundException("Zone not found"));

        String reason = "";
        boolean granted = false;

        if (!user.isInOrganization(zone.getOrgId())) {
            reason = "ORGANIZATION_MISMATCH";
        } else if (!user.hasCustomRole()) {
            reason = "ROLE_NOT_GIVEN";
        } else if (!zone.isActive()) {
            reason = "ZONE_INACTIVE";
        } else if (zone.isPublic()) {
            granted = true;
            user.setLastAccessAt(LocalDateTime.now());
            reason = "PUBLIC_ZONE";
        } else if (user.getCustomRole() != null && zone.isAllowedRole(user.getCustomRole().getId())) {
            granted = true;
            reason = "AUTHORIZED_ROLE";
        } else {
            reason = "ROLE_NOT_ALLOWED";
        }


        AccessLog log = AccessLog.builder()
                .userId(userId)
                .zoneId(zoneId)
                .zoneName(zone.getName())
                .userName(user.getFullName())
                .organizationId(zone.getOrgId())
                .timestamp(LocalDateTime.now())
                .accessGranted(granted)
                .reason(reason)
                .build(); 
        accessLogRepository.save(log);

           if ( granted) { 
            user.setLastAccessAt(LocalDateTime.now());
            userRepository.save(user);
                notificationPort.notifyResourceUpdate(
                zone.getOrgId(), 
                "USER", 
                userId, 
                Map.of("lastAccessAt", user.getLastAccessAt().toString())
            );
        }

        AccessLogResponseDTO notificationDto = mapToDto(log);

        
        AccessResponseDTO logDto =  new AccessResponseDTO(granted , reason , zone.getName()); 
        
        notificationPort.notifyEvent(zone.getOrgId(), "access-log", notificationDto);

         return logDto;

    }
    @Override
    @Transactional
    public List<AccessLogResponseDTO> getAccessLogs(Long orgaanizationId) {
        return accessLogRepository.findByOrganizationId(orgaanizationId).stream().map(this::mapToDto).toList();
    }
    private AccessLogResponseDTO mapToDto(AccessLog log) {
        return AccessLogResponseDTO.builder()
            .id(log.getId())
            .userId(log.getUserId())
            .userName(log.getUserName() != null ? log.getUserName() : "Utilisateur inconnu")
            .zoneName(log.getZoneName() != null ? log.getZoneName() : "Zone inconnue")
            .timestamp(log.getTimestamp())
            .accessGranted(log.isAccessGranted())
            .reason(log.getReason())
            .build();
    }
    @Override
    public List<AccessLog> findByUserIdOrderByTimestampDesc(Long userId, int limit) {
        return accessLogRepository.findByUserIdOrderByTimestampDesc(userId, limit) ; 
 }
    
    
}
