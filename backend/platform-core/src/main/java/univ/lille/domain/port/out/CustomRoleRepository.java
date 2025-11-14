package univ.lille.domain.port.out;

import univ.lille.domain.model.CustomRole;
import java.util.Optional;
import java.util.List;
public interface CustomRoleRepository {
    CustomRole save(CustomRole role) ;
    Optional<CustomRole> findById(Long id) ;
    List<CustomRole> getCustomRolesByOrganizationId(Long organizationId) ;
    List<CustomRole> findByIdInAndOrganizationId(List<Long> ids, Long organizationId);
    boolean existsByNameAndOrganizationId(String name, Long organizationId) ;
    int countUsersByRoleId(Long roleId) ;
    void delete(CustomRole role) ;




}
