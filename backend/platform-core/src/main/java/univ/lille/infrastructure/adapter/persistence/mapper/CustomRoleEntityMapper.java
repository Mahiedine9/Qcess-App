package univ.lille.infrastructure.adapter.persistence.mapper;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import univ.lille.domain.model.CustomRole;
import univ.lille.infrastructure.adapter.persistence.entity.CustomRoleEntity;

@Component
@RequiredArgsConstructor
public class CustomRoleEntityMapper {

private final OrganizationEntityMapper organizationEntityMapper;

    public CustomRole toDomain(CustomRoleEntity entity) {
        if (entity == null) return  null ;
        return CustomRole.builder()
                .id(entity.getId())
                .name(entity.getName())
                .description(entity.getDescription())
                .organization(entity.getOrganization() != null
                        ? organizationEntityMapper.toDomain(entity.getOrganization())
                        : null)                .createdAt(entity.getCreatedAt())
                .build();
    }
    public  CustomRoleEntity toEntity ( CustomRole domain ) {
        if( domain == null ) return null;
        return CustomRoleEntity.builder()
                .id(domain.getId())
                .name(domain.getName())
                .description(domain.getDescription())
                .organization(organizationEntityMapper.toEntity(domain.getOrganization()))
                .createdAt(domain.getCreatedAt())
                .build();
    }
}
