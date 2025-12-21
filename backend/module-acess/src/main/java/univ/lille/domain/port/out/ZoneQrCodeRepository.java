package univ.lille.domain.port.out;

import univ.lille.domain.model.ZoneQrCode;
import java.util.Optional;

public interface ZoneQrCodeRepository {
    ZoneQrCode save(ZoneQrCode qr);
    Optional<ZoneQrCode> findByZoneId(Long zoneId);
    boolean existsByZoneId(Long zoneId);
    Optional<ZoneQrCode> findByZoneIdAndOrganizationId(Long zoneId, Long organizationId);
    void deleteByZoneId(Long zoneId); 
    
}
