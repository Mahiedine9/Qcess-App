package univ.lille.application.usecase;

import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import univ.lille.domain.exception.ZoneNotFoundException;
import univ.lille.domain.model.Zone;
import univ.lille.domain.model.ZoneQrCode;
import univ.lille.domain.port.in.ZoneQrCodePort;
import univ.lille.domain.port.out.QrCodeGenerator;
import univ.lille.domain.port.out.ZoneQrCodeRepository;
import univ.lille.domain.port.out.ZoneRepository;
@Service 
@RequiredArgsConstructor
public class ZoneQrCodeUseCase implements ZoneQrCodePort {

    private final ZoneQrCodeRepository qrCodeRepository; 
    private final QrCodeGenerator qrCodeGenerator;
    private final ZoneRepository zoneRepository; 
    
    @Override
    @Transactional
    public ZoneQrCode createForZone(Long zoneId, Long orgId, String zoneName) {
        if (qrCodeRepository.existsByZoneId(zoneId)) {
            return qrCodeRepository.findByZoneId(zoneId).orElseThrow();
        }  
        String content = String.format("{\"zoneId\":%d,\"orgId\":%d,\"name\":\"%s\"}", zoneId, orgId, zoneName);
        byte[] image = qrCodeGenerator.generatePng(content, 300, 300);
        ZoneQrCode qr = ZoneQrCode.builder()
                    .zoneId(zoneId)
                    .organizationId(orgId)
                    .content(content)
                    .image(image)
                    .format("PNG")
                    .build();

        return qrCodeRepository.save(qr); 

    }

        @Override
        @Transactional
    public ZoneQrCode getByZoneId(Long zoneId, Long orgId) {
        return qrCodeRepository.findByZoneIdAndOrganizationId(zoneId, orgId)
                .orElseThrow(() -> new RuntimeException("QR Code not found for zone " + zoneId));
    }

        @Override
        @Transactional
        public ZoneQrCode regenerateForZone(Long zoneId, Long orgId)  {
            Zone zone = zoneRepository.findByIdAndOrganizationId(zoneId, orgId).orElseThrow(()->
            new ZoneNotFoundException("Zone not Found in this organization")); 

            String zoneName = zone.getName(); 
            String content = String.format("{\"zoneId\":%d,\"orgId\":%d,\"name\":\"%s\"}", zoneId, orgId, zoneName);
            byte[] image = qrCodeGenerator.generatePng(content, 300, 300); 
            ZoneQrCode qr = ZoneQrCode.builder()
                    .zoneId(zoneId)
                    .organizationId(orgId)
                    .content(content)
                    .image(image)
                    .format("PNG")
                    .build(); 
            qrCodeRepository.deleteByZoneId(zoneId);    

            return qrCodeRepository.save(qr); 

        }


    
    
}
