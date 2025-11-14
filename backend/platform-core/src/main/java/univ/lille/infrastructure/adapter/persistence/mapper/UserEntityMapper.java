package univ.lille.infrastructure.adapter.persistence.mapper;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import univ.lille.domain.model.User;
import univ.lille.infrastructure.adapter.persistence.entity.UserEntity;

@Component
@RequiredArgsConstructor
public class UserEntityMapper {
    public final OrganizationEntityMapper organizationEntityMapper;
    public final CustomRoleEntityMapper customRoleEntityMapper;

    public UserEntity toEntity(User domain) {
        if ( domain== null) return null;
        return UserEntity.builder()
                .id(domain.getId())
                .email(domain.getEmail())
                .password(domain.getPassword())
                .fullName(domain.getFullName())
                .firstName(domain.getFirstName())
                .lastName(domain.getLastName())
                .status(domain.getUserStatus())
                .role(domain.getRole())
                .organization(organizationEntityMapper.toEntity(domain.getOrganization()))
                .customRole(customRoleEntityMapper.toEntity(domain.getCustomRole()))
                .createdAt(domain.getCreatedAt())
                .loginCode(domain.getLoginCode())
                .lastLogin(domain.getLastLoginAt())
                .build();



    }

    public User toDomain(UserEntity entity) {
        if (entity == null) return null;

        return  User.builder()
                .id(entity.getId())
                .email(entity.getEmail())
                .password(entity.getPassword())
                .fullName(entity.getFullName())
                .loginCode(entity.getLoginCode())
                .firstName(entity.getFirstName())
                .lastName(entity.getLastName())
                .role(entity.getRole())
                .userStatus(entity.getStatus())
                .organization(organizationEntityMapper.toDomain(entity.getOrganization()))
                .customRole(customRoleEntityMapper.toDomain(entity.getCustomRole()))
                .createdAt(entity.getCreatedAt())
                .lastLoginAt(entity.getLastLogin())
                .build();

    }

}
