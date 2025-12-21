package univ.lille.infrastructure.adapter.persistence.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import univ.lille.infrastructure.adapter.persistence.entity.ZoneQrCodeEntity;

public interface ZoneQrCodeJpaRepository extends JpaRepository<ZoneQrCodeEntity,Long> {
    Optional<ZoneQrCodeEntity> findByZoneId(Long zoneId);
    boolean existsByZoneId(Long zoneId);

    Optional<ZoneQrCodeEntity> findByZoneIdAndOrganizationId(Long zoneId, Long organizationId);
    @Modifying
    @Query("DELETE FROM ZoneQrCodeEntity z WHERE z.zoneId = :zoneId")
    void deleteByZoneId(Long zoneId) ; 
}
