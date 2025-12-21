package univ.lille.domain.port.in;

import univ.lille.domain.model.ZoneQrCode;

public interface ZoneQrCodePort {

    ZoneQrCode createForZone(Long zoneId, Long orgId , String zoneName) ; 
    ZoneQrCode getByZoneId( Long zoneId, Long orgId) ; 
    ZoneQrCode regenerateForZone (Long zoneId, Long orgId) ; 

    
    
    
}
