package univ.lille.infrastructure.adapter.persistence;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import univ.lille.domain.model.ZoneQrCode;
import univ.lille.infrastructure.adapter.persistence.entity.ZoneQrCodeEntity;
import univ.lille.infrastructure.adapter.persistence.repository.ZoneQrCodeJpaRepository;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ZoneQrCodeRepositoryAdapterTest {

    @Mock
    private ZoneQrCodeJpaRepository jpaRepository;

    @InjectMocks
    private ZoneQrCodeRepositoryAdapter adapter;

    @Test
    void save_ShouldMapAndSave() {
        ZoneQrCode qr = ZoneQrCode.builder()
                .zoneId(1L)
                .organizationId(2L)
                .content("data")
                .build();

        ZoneQrCodeEntity savedEntity = new ZoneQrCodeEntity();
        savedEntity.setId(10L);
        savedEntity.setZoneId(1L);
        savedEntity.setOrganizationId(2L);
        savedEntity.setContent("data");

        when(jpaRepository.save(any(ZoneQrCodeEntity.class))).thenReturn(savedEntity);

        ZoneQrCode result = adapter.save(qr);

        assertEquals(10L, result.getId());
        assertEquals("data", result.getContent());
        verify(jpaRepository).save(any(ZoneQrCodeEntity.class));
    }

    @Test
    void findByZoneId_Found() {
        ZoneQrCodeEntity entity = new ZoneQrCodeEntity();
        entity.setId(1L);
        entity.setZoneId(5L);

        when(jpaRepository.findByZoneId(5L)).thenReturn(Optional.of(entity));

        Optional<ZoneQrCode> result = adapter.findByZoneId(5L);

        assertTrue(result.isPresent());
        assertEquals(1L, result.get().getId());
    }

    @Test
    void existsByZoneId() {
        when(jpaRepository.existsByZoneId(5L)).thenReturn(true);
        assertTrue(adapter.existsByZoneId(5L));
    }

    @Test
    void findByZoneIdAndOrganizationId() {
        ZoneQrCodeEntity entity = new ZoneQrCodeEntity();
        entity.setId(1L);
        when(jpaRepository.findByZoneIdAndOrganizationId(5L, 10L)).thenReturn(Optional.of(entity));

        Optional<ZoneQrCode> result = adapter.findByZoneIdAndOrganizationId(5L, 10L);

        assertTrue(result.isPresent());
        assertEquals(1L, result.get().getId());
    }
}
