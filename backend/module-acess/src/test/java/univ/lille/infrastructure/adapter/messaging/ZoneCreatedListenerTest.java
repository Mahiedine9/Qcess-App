package univ.lille.infrastructure.adapter.messaging;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import univ.lille.domain.port.in.ZoneQrCodePort;
import univ.lille.events.ZoneCreatedEvent;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ZoneCreatedListenerTest {

    @Mock
    private ZoneQrCodePort zoneQrCodePort;

    @InjectMocks
    private ZoneCreatedListener listener;

    @Test
    void onZoneCreated_should_call_qrcode_creation() {
        // Given
        ZoneCreatedEvent event = new ZoneCreatedEvent(
                this,
                10L,
                100L,
                "Test Zone"
        );

        // When
        listener.onZoneCreated(event);

        // Then
        ArgumentCaptor<Long> zoneIdCaptor = ArgumentCaptor.forClass(Long.class);
        ArgumentCaptor<Long> orgIdCaptor = ArgumentCaptor.forClass(Long.class);
        ArgumentCaptor<String> nameCaptor = ArgumentCaptor.forClass(String.class);

        verify(zoneQrCodePort).createForZone(
                zoneIdCaptor.capture(),
                orgIdCaptor.capture(),
                nameCaptor.capture()
        );

        assertThat(zoneIdCaptor.getValue()).isEqualTo(10L);
        assertThat(orgIdCaptor.getValue()).isEqualTo(100L);
        assertThat(nameCaptor.getValue()).isEqualTo("Test Zone");
    }

    @Test
    void onZoneCreated_should_handle_exception_gracefully() {
        // Given
        ZoneCreatedEvent event = new ZoneCreatedEvent(
                this,
                10L,
                100L,
                "Test Zone"
        );

        doThrow(new RuntimeException("QR Generation failed"))
                .when(zoneQrCodePort).createForZone(anyLong(), anyLong(), anyString());

        // When & Then - Should not throw exception
        listener.onZoneCreated(event);

        verify(zoneQrCodePort).createForZone(10L, 100L, "Test Zone");
    }
}
