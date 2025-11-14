package univ.lille.infrastructure.adapter.persistence.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import univ.lille.infrastructure.adapter.persistence.entity.OrganizationEntity;

import java.util.Optional;
@Repository
public interface OrganizationJpaRepository extends JpaRepository<OrganizationEntity, Long> {

    Optional<OrganizationEntity> findByName(String name);

}
