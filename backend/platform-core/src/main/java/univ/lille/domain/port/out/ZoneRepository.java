package univ.lille.domain.port.out;

import univ.lille.domain.model.Zone;
import java.util.List;

public interface ZoneRepository {
    Zone save(Zone zone);
    Zone findByQrCode(String qrCode);
    Zone findById(Long id);
    List<Zone> findByOrganizationId(Long organizationId);
    boolean existsByNameAndOrganizationId(String name, Long organizationId);
    void delete(Zone zone);


}
