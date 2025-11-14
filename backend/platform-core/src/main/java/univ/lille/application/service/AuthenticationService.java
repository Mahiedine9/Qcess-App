package univ.lille.application.service;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import univ.lille.domain.exception.UserNotFoundException;
import univ.lille.domain.model.User;
import univ.lille.domain.port.out.UserRepository;
import org.springframework.security.core.Authentication;
import univ.lille.infrastructure.adapter.security.QcessUserPrincipal;


@Service
@RequiredArgsConstructor
public class AuthenticationService {
    private final UserRepository userRepository;
    public Long getCurrentUserId() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new UserNotFoundException("Aucun utilisateur connecté");
        }
        var principal = (QcessUserPrincipal) auth.getPrincipal();
        return principal.getId();
    }

    public Long getCurrentUserOrganizationId() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new UserNotFoundException("Aucun utilisateur connecté");
        }
        var principal = (QcessUserPrincipal) auth.getPrincipal();
        return principal.getOrganizationId();
    }

    public String getCurrentUserEmail() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        return (auth != null && auth.isAuthenticated()) ? auth.getName() : null;
    }



    public User getCurrentUser() {
        String email = getCurrentUserEmail();
        if (email == null) {
            throw new UserNotFoundException("Aucun utilisateur connecté");
        }
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UserNotFoundException("Utilisateur non trouvé avec l'email: " + email));
    }
}
