package univ.lille.infrastructure.adapter.persistence;

import java.util.Optional;

import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;
import univ.lille.domain.model.ZoneQrCode;
import univ.lille.domain.port.out.ZoneQrCodeRepository;
import univ.lille.infrastructure.adapter.persistence.entity.ZoneQrCodeEntity;
import univ.lille.infrastructure.adapter.persistence.repository.ZoneQrCodeJpaRepository;
@Component
@RequiredArgsConstructor
public class ZoneQrCodeRepositoryAdapter implements ZoneQrCodeRepository {
    private final ZoneQrCodeJpaRepository jpaRepository;
    @Override
    public ZoneQrCode save(ZoneQrCode qr) {
        ZoneQrCodeEntity entity = new ZoneQrCodeEntity(); 
        if (qr.getId() != null) entity.setId(qr.getId());
        entity.setZoneId(qr.getZoneId());
        entity.setOrganizationId(qr.getOrganizationId());
        entity.setContent(qr.getContent());
        entity.setImage(qr.getImage());
        entity.setFormat(qr.getFormat());
        ZoneQrCodeEntity saved = jpaRepository.save(entity); 
        return mapToDomain(saved); 
   
    }

    @Override
    public Optional<ZoneQrCode> findByZoneId(Long zoneId) {
        return jpaRepository.findById(zoneId).map(this::mapToDomain); 
    }

    @Override
    public boolean existsByZoneId(Long zoneId) {
        return jpaRepository.existsByZoneId(zoneId); 
    }
    @Override
    public Optional<ZoneQrCode> findByZoneIdAndOrganizationId(Long zoneId, Long organizationId) {
        return jpaRepository.findByZoneIdAndOrganizationId(zoneId, organizationId).map(this:: mapToDomain); 
    }
    private ZoneQrCode mapToDomain(ZoneQrCodeEntity entity) {
        return ZoneQrCode.builder()
                .id(entity.getId())
                .zoneId(entity.getZoneId())
                .organizationId(entity.getOrganizationId())
                .content(entity.getContent())
                .image(entity.getImage())
                .format(entity.getFormat())
                .build();
    }

    @Override
    public void deleteByZoneId(Long zoneId) {
           jpaRepository.deleteByZoneId(zoneId); 
    }


}
