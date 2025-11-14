package univ.lille.infrastructure.adapter.persistence;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import univ.lille.domain.model.User;
import univ.lille.domain.port.out.UserRepository;
import univ.lille.infrastructure.adapter.persistence.entity.UserEntity;
import univ.lille.infrastructure.adapter.persistence.mapper.UserEntityMapper;
import univ.lille.infrastructure.adapter.persistence.repository.OrganizationJpaRepository;
import univ.lille.infrastructure.adapter.persistence.repository.UserJpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class UserRepositoryAdapter implements UserRepository {
    public final UserJpaRepository userJpaRepository;
    public final UserEntityMapper mapper;
    @Override
    public User save(User user) {
        UserEntity entity = mapper.toEntity(user);
        UserEntity savedEntity = userJpaRepository.save(entity);
        return  mapper.toDomain(savedEntity);
    }

    @Override
    public Optional<User> findById(Long id) {
        return userJpaRepository.findById(id)
                .map(mapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findByEmail(String email) {
        return userJpaRepository.findByEmailWithOrganization(email)
                .map(mapper::toDomain);
    }
    @Override
    public boolean existsByEmail(String email) {
        return userJpaRepository.existsByEmail(email);
    }

    @Override
    public List<User> findAll() {
        return userJpaRepository.findAll()
                .stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
    }

    @Override
    public List<User> findByOrganizationId(Long organizationId) {
        return userJpaRepository.findByOrganization_Id(organizationId)
                .stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
    }



    @Override
    public void deleteUser(User user) {
        userJpaRepository.delete(mapper.toEntity(user));

    }
}
