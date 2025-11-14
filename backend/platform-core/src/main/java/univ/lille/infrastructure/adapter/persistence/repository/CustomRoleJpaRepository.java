package univ.lille.infrastructure.adapter.persistence.repository;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import univ.lille.domain.model.CustomRole;
import univ.lille.infrastructure.adapter.persistence.entity.CustomRoleEntity;
import java.util.List;
import java.util.Optional;
@Repository
public interface CustomRoleJpaRepository extends JpaRepository<CustomRoleEntity , Long> {
    List<CustomRoleEntity> findByOrganization_Id(Long organizationId);
    List<CustomRole> getCustomRolesByOrganizationId(Long organizationId) ;

    List<CustomRoleEntity> findByIdInAndOrganization_Id(List<Long> ids, Long organizationId);
    Optional<CustomRoleEntity> findByNameAndOrganization_Id(String name, Long organizationId);
    @Query("SELECT COUNT(u) FROM UserEntity u WHERE u.customRole.id = :roleId")
    long countUsersByRoleId(@Param("roleId") Long roleId) ;

}
