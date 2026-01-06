package univ.lille.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import univ.lille.domain.port.in.ZoneManagementPort;
import univ.lille.dto.zone.AllowedRolesRequest;
import univ.lille.dto.zone.CreateZoneRequest;
import univ.lille.dto.zone.UpdateZoneRequest;
import univ.lille.dto.zone.ZoneDTO;
import univ.lille.infrastructure.adapter.security.QcessUserPrincipal;

import java.util.List;

@RestController
@RequestMapping("/api/zones")
@RequiredArgsConstructor
public class ZoneController {
    private final ZoneManagementPort zonePort;


    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ZoneDTO> createZone(@Valid @RequestBody CreateZoneRequest request , @AuthenticationPrincipal QcessUserPrincipal principal) {

        ZoneDTO zoneDTO = zonePort.createZone(request,principal.getOrganizationId()) ;
        return  ResponseEntity.status(HttpStatus.CREATED).body(zoneDTO);
    }
     @DeleteMapping("/delete/{zoneId}")
     @PreAuthorize("hasRole('ADMIN')")
     public ResponseEntity<String> deleteZone(@PathVariable("zoneId") Long zoneId, @AuthenticationPrincipal QcessUserPrincipal principal) {
        Long adminId = principal.getId();
        Long orgId = principal.getOrganizationId();
        zonePort.deleteZone( zoneId ,orgId) ;
        return ResponseEntity.ok("Zone deleted successfully") ;
     }

    @GetMapping("/{zoneId}")
    public ResponseEntity<ZoneDTO> getZone(@PathVariable("zoneId") Long zoneId , @AuthenticationPrincipal QcessUserPrincipal principal) {

        ZoneDTO zoneDTO = zonePort.getZone(principal.getOrganizationId(),zoneId);
        return ResponseEntity.ok(zoneDTO);
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ZoneDTO>> getZonesForOrg(@AuthenticationPrincipal QcessUserPrincipal principal) {
        Long orgId = principal.getOrganizationId();
        List<ZoneDTO> zones = zonePort.getZonesForOrg(orgId);
        return ResponseEntity.ok(zones);
    }

    @GetMapping("/me/accessible")
    public ResponseEntity<List<ZoneDTO>> getAccessibleZonesForCurrentUser(
            @AuthenticationPrincipal QcessUserPrincipal principal) {
        List<ZoneDTO> zones = zonePort.getAccessibleZonesForUser(
                principal.getId(),
                principal.getOrganizationId()
        );
        return ResponseEntity.ok(zones);
    }

    @PatchMapping("/{zoneId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ZoneDTO> updateZone (@PathVariable("zoneId") Long zoneId ,@Valid @RequestBody UpdateZoneRequest request, @AuthenticationPrincipal QcessUserPrincipal principal) {
        Long orgId = principal.getOrganizationId();
        ZoneDTO updated = zonePort.updateZone(zoneId,request,orgId ) ;
        return  ResponseEntity.ok(updated);
    }
    @PostMapping("/{zoneId}/allowed-roles")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> addAllowedRolesToZone(@PathVariable("zoneId") Long zoneId ,@Valid @RequestBody AllowedRolesRequest request , @AuthenticationPrincipal QcessUserPrincipal principal
    ){
        Long orgId = principal.getOrganizationId();
        zonePort.addAllowedRolesToZone(zoneId,request.getRoleIds(),orgId);
        return ResponseEntity.ok("Roles added successfully to zone");
    }

    /**
     * Remplacer complètement la liste des allowedRoles d'une zone.
     * Si la liste est vide -> la zone devient inaccessible (sauf admin).
     */
    @PutMapping("/{zoneId}/allowed-roles")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> replaceAllowedRolesForZone(@PathVariable("zoneId") Long zoneId,
                                                           @Valid @RequestBody AllowedRolesRequest request,
                                                           @AuthenticationPrincipal QcessUserPrincipal principal) {
            Long orgId = principal.getOrganizationId();
            zonePort.replaceAllowedRolesForZone(zoneId,request.getRoleIds(),orgId);
            return  ResponseEntity.ok("Roles replaced successfully") ;

    }

    @DeleteMapping("/{zoneId}/allowed-roles/{roleId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> removeAllowedRoleFromZone(@PathVariable("zoneId") Long zoneId,
                                                          @PathVariable("roleId") Long roleId,
                                                          @AuthenticationPrincipal QcessUserPrincipal principal) {
        Long orgId = principal.getOrganizationId();

        zonePort.removeAllowedRoleFromZone(zoneId, roleId, orgId);

        return ResponseEntity.ok("Role removed successfully");
    }
}
