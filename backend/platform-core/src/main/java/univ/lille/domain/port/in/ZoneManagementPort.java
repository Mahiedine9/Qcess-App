package univ.lille.domain.port.in;

import univ.lille.dto.zone.CreateZoneRequest;
import univ.lille.dto.zone.UpdateZoneRequest;
import univ.lille.dto.zone.ZoneDTO;

import java.util.List;

public interface ZoneManagementPort {

    ZoneDTO createZone (CreateZoneRequest request, Long orgId) ;
    ZoneDTO getZone( Long orgId, Long zoneId) ;

    void deleteZone (Long zoneId , Long orgId) ;

    ZoneDTO updateZone (Long zoneId , UpdateZoneRequest request, Long orgId) ;
     void replaceAllowedRolesForZone(Long zoneId, List<Long> roleIds, Long orgId) ;
     void removeAllowedRoleFromZone(Long zoneId, Long roleId, Long orgId) ;
    void addAllowedRolesToZone(Long zoneId, List<Long> roleIds, Long orgId);

    List<ZoneDTO> getZonesForOrg(Long orgId) ;
    List<ZoneDTO> getAccessibleZonesForUser(Long userId, Long orgId);
    //ZoneDTO updateZone( );
}
