package univ.lille.infrastructure.adapter.persistence.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import univ.lille.infrastructure.adapter.persistence.entity.BlackListedToken;

public interface BlacklistedTokenRepository extends JpaRepository<BlackListedToken, Long> {
    boolean existsByToken(String token);
}
