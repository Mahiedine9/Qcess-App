package univ.lille.infrastructure.adapter.persistence;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import univ.lille.domain.model.CustomRole;
import univ.lille.domain.port.out.CustomRoleRepository;
import univ.lille.infrastructure.adapter.persistence.entity.CustomRoleEntity;
import univ.lille.infrastructure.adapter.persistence.mapper.CustomRoleEntityMapper;
import univ.lille.infrastructure.adapter.persistence.repository.CustomRoleJpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class CustomRoleRepositoryAdapter implements CustomRoleRepository {

    private  final CustomRoleEntityMapper mapper;
    private final CustomRoleJpaRepository customRoleJpaRepository;

    @Override
    public CustomRole save(CustomRole role) {
        CustomRoleEntity entity = mapper.toEntity(role);
        CustomRoleEntity savedEntity = customRoleJpaRepository.save(entity);
        return  mapper.toDomain(savedEntity);
    }

    @Override
    public Optional<CustomRole> findById(Long id) {
        return customRoleJpaRepository.findById(id)
                .map(mapper::toDomain);
    }

    @Override
    public List<CustomRole> getCustomRolesByOrganizationId(Long organizationId) {
        List<CustomRoleEntity> entities = customRoleJpaRepository.findByOrganization_Id(organizationId);
        return entities.stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
    }

    @Override
    public List<CustomRole> findByIdInAndOrganizationId(List<Long> ids, Long organizationId) {
        List<CustomRoleEntity> entities = customRoleJpaRepository.findByIdInAndOrganization_Id(ids, organizationId);
        return entities.stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
        }

    @Override
    public boolean existsByNameAndOrganizationId(String name, Long organizationId) {
        return customRoleJpaRepository.findByNameAndOrganization_Id(name, organizationId).isPresent();

    }

    @Override
    public int countUsersByRoleId(Long roleId) {
        long count = customRoleJpaRepository.countUsersByRoleId(roleId);
        return (int) count;
    }

    @Override
    public void delete(CustomRole role) {
        customRoleJpaRepository.delete(mapper.toEntity(role));
    }
}
