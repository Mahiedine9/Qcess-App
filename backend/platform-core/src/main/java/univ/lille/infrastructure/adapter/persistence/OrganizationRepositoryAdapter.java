package univ.lille.infrastructure.adapter.persistence;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import univ.lille.domain.model.Organization;
import univ.lille.domain.port.out.OrganizationRepository;
import univ.lille.infrastructure.adapter.persistence.entity.OrganizationEntity;
import univ.lille.infrastructure.adapter.persistence.mapper.OrganizationEntityMapper;
import univ.lille.infrastructure.adapter.persistence.repository.OrganizationJpaRepository;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class OrganizationRepositoryAdapter implements OrganizationRepository {
    public final OrganizationJpaRepository organizationJpaRepository;
    public final OrganizationEntityMapper mapper;

    @Override
    public Organization save(Organization organization) {
        OrganizationEntity entity = mapper.toEntity(organization);
        OrganizationEntity orgEntitySaved = organizationJpaRepository.save(entity);
        return  mapper.toDomain(orgEntitySaved);
    }

    @Override
    public Optional<Organization> findById(Long id) {
        return organizationJpaRepository.findById(id)
                .map(mapper::toDomain);
    }

    @Override
    public Optional<Organization> findByName(String name) {
        return organizationJpaRepository.findByName(name)
                .map(mapper::toDomain);
    }



    @Override
    public void delete(Organization organization) {
        organizationJpaRepository.delete(mapper.toEntity(organization));

    }
}
