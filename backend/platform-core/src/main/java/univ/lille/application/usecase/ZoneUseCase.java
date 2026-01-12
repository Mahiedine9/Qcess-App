package univ.lille.application.usecase;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import univ.lille.application.usecase.mapper.ZoneMapper;
import univ.lille.domain.exception.CustomRoleException;
import univ.lille.domain.exception.ZoneNotFoundException;
import univ.lille.domain.model.CustomRole;
import univ.lille.domain.model.Zone;
import univ.lille.domain.port.in.ZoneManagementPort;
import univ.lille.domain.port.out.CustomRoleRepository;
import univ.lille.domain.port.out.ZoneEventPublisher;
import univ.lille.domain.port.out.ZoneRepository;
import univ.lille.dto.zone.CreateZoneRequest;
import univ.lille.dto.zone.UpdateZoneRequest;
import univ.lille.dto.zone.ZoneDTO;
import univ.lille.enums.ZoneStatus;
import univ.lille.events.ZoneCreatedEvent;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static univ.lille.application.usecase.mapper.ZoneMapper.toDTO;

@Service
@RequiredArgsConstructor
@Transactional
public class ZoneUseCase implements ZoneManagementPort {

    private final ZoneRepository zoneRepository ;
    private final ZoneEventPublisher eventPublisher ;
    private final CustomRoleRepository customRoleRepository ;


    /**
     * @param request
     * @return
     */
    @Override
    public ZoneDTO createZone(CreateZoneRequest request, Long orgId) {
        Zone zone = Zone.builder()
                .orgId(orgId)
                .name(request.getName())
                .createdAt(LocalDateTime.now())
                .description(request.getDescription())
                .status(ZoneStatus.ACTIVE)
                .build();
        Zone zoneSaved = zoneRepository.save(zone);

        ZoneCreatedEvent event = new ZoneCreatedEvent(
                this,
                zoneSaved.getId(),
                zoneSaved.getOrgId(),
                zoneSaved.getName()
        );
        eventPublisher.publishZoneCreated(event);
        return toDTO(zoneSaved);

    }


    /**
     * @param orgId
     * @param zoneId
     * @return
     */
    @Override
    public ZoneDTO getZone(Long orgId, Long zoneId) {
        Zone zone = zoneRepository.findByIdAndOrganizationId(zoneId, orgId)
                .orElseThrow(() -> new ZoneNotFoundException("Zone not found"));
        return toDTO(zone);
    }

    /**
     * @param zoneId
     * @param orgId
     */
    @Override
    @Transactional
    public void deleteZone(Long zoneId, Long orgId) {
        Zone zone = zoneRepository.findByIdAndOrganizationId(zoneId,orgId).orElseThrow(()->
                new ZoneNotFoundException("Zone not found") );
        if (zone.getStatus() == ZoneStatus.INACTIVE) {
            return;
        }
        zone.setStatus(ZoneStatus.INACTIVE);

        zone.getAllowedRoleIds().clear();

        zoneRepository.save(zone);
    }

    /**
     * @param zoneId
     * @param request
     * @param orgId
     * @return
     */
    @Override
    public ZoneDTO updateZone(Long zoneId, UpdateZoneRequest request, Long orgId) {
       Zone zone = zoneRepository.findByIdAndOrganizationId(zoneId,orgId).orElseThrow(()->
               new ZoneNotFoundException("Zone not found"));
        if (request.getName() != null && !request.getName().isBlank()) {
            zone.setName(request.getName());
        }
        if (request.getDescription() != null) {
            zone.setDescription(request.getDescription());
        }
        Zone zoneSaved = zoneRepository.save(zone);
        return toDTO(zoneSaved);
    }

    /**
     * @param zoneId
     * @param roleIds
     * @param orgId
     */
    @Override
    public void addAllowedRolesToZone(Long zoneId, List<Long> roleIds, Long orgId) {
        Zone zone = loadZoneFromRepo(zoneId,orgId);

        if (roleIds == null || roleIds.isEmpty()) { return; }
        verifyRoleExistenceInOrg(roleIds, orgId);

        roleIds.forEach(zone::addAllowedRole);
        zoneRepository.save(zone);
    }

    /**
     * @param zoneId
     * @param roleId
     * @param orgId
     */
    @Override
    public void removeAllowedRoleFromZone(Long zoneId, Long roleId, Long orgId) {
        Zone zone = loadZoneFromRepo(zoneId, orgId);


        if (!customRoleRepository.existsByIdAndOrganizationId(roleId,orgId)) {
            throw new CustomRoleException("this role doesn't exist in this organization");
        }
        zone.removeAllowedRole(roleId);

        zoneRepository.save(zone);
        //event publisher after
    }

    /**
     * @param zoneId
     * @param roleIds
     * @param orgId
     */
    @Override
    public void replaceAllowedRolesForZone(Long zoneId, List<Long> roleIds, Long orgId) {
        Zone zone = loadZoneFromRepo(zoneId, orgId);

        if ( roleIds==null || roleIds.isEmpty()) {
            zone.getAllowedRoleIds().clear();
            zoneRepository.save(zone) ;
            //event publisher
            return;
        }

       verifyRoleExistenceInOrg(roleIds, orgId);

        zone.getAllowedRoleIds().clear();
        roleIds.forEach(zone::addAllowedRole);

        zoneRepository.save(zone);

    }

    private List<CustomRole> verifyRoleExistenceInOrg(List<Long> roleIds, Long orgId) {
        List<CustomRole> roles = customRoleRepository.findByIdInAndOrganizationId(roleIds,orgId) ;
        Set<Long> distinctIds = new HashSet<>(roleIds);
        Set<Long> foundIds = new HashSet<>(
                roles.stream().map(CustomRole::getId).toList()
        );

        verifyRoles(foundIds,distinctIds);
        return roles ;
    }

    /**
     * @param orgId
     * @return
     */
    @Override
    public List<ZoneDTO> getZonesForOrg(Long orgId) {
      List<Zone> zones =   zoneRepository.findByOrganizationIdAndStatus(orgId,ZoneStatus.ACTIVE);

        return zones.stream()
                .map(ZoneMapper::toDTO)
                .toList();
    }

    private Zone loadZoneFromRepo(Long zoneId, Long orgId) {
        return zoneRepository.findByIdAndOrganizationId(zoneId, orgId)
                .orElseThrow(() -> new ZoneNotFoundException("Zone not found"));
    }

    private  void verifyRoles(Set<Long> foundIds , Set<Long> distinctIds) {
        if (!foundIds.containsAll(distinctIds)) {
            throw  new CustomRoleException("Un ou plusieurs rôles n'existent pas dans l'organisation");
        }
    }


}

