
package univ.lille.application.usecase;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import univ.lille.domain.exception.UserNotFoundException;
import univ.lille.domain.exception.ZoneNotFoundException;
import univ.lille.domain.model.AccessLog;
import univ.lille.domain.model.CustomRole;
import univ.lille.domain.model.Organization;
import univ.lille.domain.model.User;
import univ.lille.domain.model.Zone;
import univ.lille.domain.port.out.AccessLogRepository;
import univ.lille.domain.port.out.NotificationPort; 
import univ.lille.domain.port.out.UserRepository;
import univ.lille.domain.port.out.ZoneRepository;
import univ.lille.dto.access.AccessResponseDTO;
import univ.lille.enums.ZoneStatus;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AccessControlUseCaseTest {

    @Mock
    private ZoneRepository zoneRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private AccessLogRepository accessLogRepository;
    @Mock
    private NotificationPort notificationPort;

    @InjectMocks
    private AccessControlUseCase accessControlUseCase;

    // Méthode helper pour créer une organisation
    private Organization createOrganization(Long id) {
        return Organization.builder()
                .id(id)
                .name("Test Organization")
                .build();
    }

    @Test
    void validateAccess_UserNotFound_ThrowsException() {
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        assertThrows(UserNotFoundException.class, () -> accessControlUseCase.validateAccess(1L, 1L));
        verifyNoInteractions(zoneRepository, accessLogRepository);
    }

        @Test
    void user_domain_methods_should_work() {
        Organization org = createOrganization(10L);
        CustomRole role = CustomRole.builder().id(5L).name("Staff").build();
        User user = User.builder()
                .id(1L)
                .organization(org)
                .customRole(role)
                .build();

        assertTrue(user.isInOrganization(10L));
        assertFalse(user.isInOrganization(99L));
        assertTrue(user.hasCustomRole());
        user.removeRole();
        assertFalse(user.hasCustomRole());
    }

    @Test
    void zone_domain_methods_should_work() {
        Zone zone = Zone.builder()
                .id(1L)
                .status(ZoneStatus.ACTIVE)
                .orgId(10L)
                .allowedRoleIds(List.of(5L, 6L))
                .build();
        assertTrue(zone.isActive());
        assertFalse(zone.isPublic());
        assertTrue(zone.isAllowedRole(5L));
        assertFalse(zone.isAllowedRole(99L));

        Zone publicZone = Zone.builder()
                .id(2L)
                .status(ZoneStatus.ACTIVE)
                .orgId(10L)
                .allowedRoleIds(null)
                .build();
        assertTrue(publicZone.isPublic());
    }

    @Test
    void validateAccess_ZoneNotFound_ThrowsException() {
        Organization org = createOrganization(10L);
        User user = User.builder().id(1L).organization(org).build();
        
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(zoneRepository.findById(1L)).thenReturn(Optional.empty());

        assertThrows(ZoneNotFoundException.class, () -> accessControlUseCase.validateAccess(1L, 1L));
        verifyNoInteractions(accessLogRepository);
    }

    @Test
    void validateAccess_ZoneInactive_AccessDenied() {
        Organization org = createOrganization(10L);
        CustomRole role = CustomRole.builder().id(1L).name("TestRole").build();
        User user = User.builder()
                .id(1L)
                .organization(org)
                .customRole(role)
                .firstName("John")
                .lastName("Doe")
                .build();

        Zone zone = Zone.builder()
                .id(1L)
                .status(ZoneStatus.INACTIVE)
                .orgId(10L)
                .name("Zone A")
                .build();

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(zoneRepository.findById(1L)).thenReturn(Optional.of(zone));

        AccessResponseDTO response = accessControlUseCase.validateAccess(1L, 1L);

        assertFalse(response.isGranted());
        assertEquals("ZONE_INACTIVE", response.getReason());
        verify(accessLogRepository).save(any(AccessLog.class));
    }

    @Test
    void validateAccess_PublicZone_AccessGranted() {
        Organization org = createOrganization(10L);
        CustomRole role = CustomRole.builder().id(1L).name("TestRole").build();
        User user = User.builder()
                .id(1L)
                .organization(org)
                .customRole(role)
                .firstName("John")
                .lastName("Doe")
                .build();

        // Zone publique : allowedRoleIds est null ou vide
        Zone zone = Zone.builder()
                .id(1L)
                .status(ZoneStatus.ACTIVE)
                .orgId(10L)
                .name("Zone A")
                .allowedRoleIds(null)
                .build();

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(zoneRepository.findById(1L)).thenReturn(Optional.of(zone));

        AccessResponseDTO response = accessControlUseCase.validateAccess(1L, 1L);

        assertTrue(response.isGranted());
        assertEquals("PUBLIC_ZONE", response.getReason());
        verify(accessLogRepository).save(any(AccessLog.class));
        verify(userRepository).save(user); // Vérifie que lastAccessAt a été mis à jour
    }

    @Test
    void validateAccess_AuthorizedRole_AccessGranted() {
        Organization org = createOrganization(10L);
        CustomRole role = CustomRole.builder().id(5L).name("Staff").build();
        
        User user = User.builder()
                .id(1L)
                .organization(org)
                .customRole(role)
                .firstName("Jane")
                .lastName("Smith")
                .build();
        
        Zone zone = Zone.builder()
                .id(1L)
                .status(ZoneStatus.ACTIVE)
                .orgId(10L)
                .name("Zone A")
                .allowedRoleIds(List.of(5L))
                .build();

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(zoneRepository.findById(1L)).thenReturn(Optional.of(zone));

        AccessResponseDTO response = accessControlUseCase.validateAccess(1L, 1L);

        assertTrue(response.isGranted());
        assertEquals("AUTHORIZED_ROLE", response.getReason());
        verify(accessLogRepository).save(any(AccessLog.class));
        verify(userRepository).save(user); // Vérifie que lastAccessAt a été mis à jour
    }

    @Test
    void validateAccess_RoleNotAllowed_AccessDenied() {
        Organization org = createOrganization(10L);
        CustomRole role = CustomRole.builder().id(99L).name("Guest").build();
        
        User user = User.builder()
                .id(1L)
                .organization(org)
                .customRole(role)
                .firstName("Bob")
                .lastName("Martin")
                .build();
        
        Zone zone = Zone.builder()
                .id(1L)
                .status(ZoneStatus.ACTIVE)
                .orgId(10L)
                .name("Zone A")
                .allowedRoleIds(List.of(5L))
                .build();

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(zoneRepository.findById(1L)).thenReturn(Optional.of(zone));

        AccessResponseDTO response = accessControlUseCase.validateAccess(1L, 1L);

        assertFalse(response.isGranted());
        assertEquals("ROLE_NOT_ALLOWED", response.getReason());
        verify(accessLogRepository).save(any(AccessLog.class));
    }
}
