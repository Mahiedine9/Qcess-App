package univ.lille.application.usecase;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import univ.lille.domain.exception.InvalidCredentialsException;
import univ.lille.domain.exception.UserNotFoundException;
import univ.lille.domain.model.User;
import univ.lille.domain.port.in.LoginUserPort;
import univ.lille.domain.port.out.UserRepository;
import univ.lille.dto.auth.AuthResponse;
import univ.lille.dto.auth.LoginRequest;
import univ.lille.enums.UserRole;
import univ.lille.enums.UserStatus;
import univ.lille.infrastructure.adapter.security.JwtService;

@Service
@RequiredArgsConstructor
@Slf4j
public class LoginUseCase implements LoginUserPort {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    /**méthode de login
     * @param loginRequest
     * @return AuthResponse
     * */
    @Override
    @Transactional
    public AuthResponse login(LoginRequest loginRequest) {
        User user = getUserByEmail(loginRequest.getEmail());

        loginByRole(user, loginRequest);

        user.updateLastLogin();
        userRepository.save(user);
        String token = jwtService.generateToken(user);
        log.info("Login successful for user: {}", user.getEmail());
        return new AuthResponse(token, user.getEmail(), user.getRole(), user.getOrganization().getId());


}
/**méthode de login par rôle
 * @param user
 * @param loginRequest
 * */
private void loginByRole ( User user, LoginRequest loginRequest  ) {
    if (user.getRole()== UserRole.ADMIN ) {
       verifyAdminCredentials( loginRequest, user);

    } else {
        verifyUserCredentials(loginRequest,user);

        if (user.getUserStatus() == UserStatus.PENDING) {
            user.activate();
        }
    }}


    /** méthode de vérification des credentials admin
    * @param loginRequest
    * @param user
     * @exception InvalidCredentialsException si les credentials sont invalides
    */
    private void verifyAdminCredentials( LoginRequest loginRequest, User user) {
        if (loginRequest.getPassword() == null || !passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            throw new InvalidCredentialsException("Invalid credentials");

        }
    }
    /**méthode de vérification des credentials user
     * @param loginRequest
     * @param user
     * @exception InvalidCredentialsException si les credentials sont invalides
     * */
    private void verifyUserCredentials( LoginRequest loginRequest, User user) {
        if (loginRequest.getLoginCode() == null || !loginRequest.getLoginCode().equals(user.getLoginCode())) {
            throw new InvalidCredentialsException("Invalid credentials");
        }
    }
/**méthode de récupération de l'utilisateur par email
 * @param email
 * @return User
 * */
private User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UserNotFoundException("User not found with email: " + email));
    }
}
