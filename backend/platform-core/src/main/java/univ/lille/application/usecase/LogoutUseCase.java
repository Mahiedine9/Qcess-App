package univ.lille.application.usecase;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import univ.lille.infrastructure.adapter.persistence.entity.BlackListedToken;
import univ.lille.infrastructure.adapter.persistence.repository.BlacklistedTokenRepository;

@Service
@RequiredArgsConstructor
public class LogoutUseCase {

    private final BlacklistedTokenRepository blacklistedTokenRepository;


    public void logout(String token) {
        BlackListedToken blackListedToken = BlackListedToken.builder()
                .token(token)
                .build();
        blacklistedTokenRepository.save(blackListedToken);
    }
}
