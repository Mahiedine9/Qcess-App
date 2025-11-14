package univ.lille.application.usecase;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import univ.lille.application.utils.NameUtils;
import univ.lille.domain.exception.EmailAlreadyExistsException;
import univ.lille.domain.model.Organization;
import univ.lille.domain.model.User;
import univ.lille.domain.port.in.RegisterAdminPort;
import univ.lille.domain.port.out.EmailPort;
import univ.lille.domain.port.out.OrganizationRepository;
import univ.lille.domain.port.out.UserRepository;
import univ.lille.dto.auth.AuthResponse;
import univ.lille.dto.auth.RegisterRequest;
import univ.lille.enums.UserRole;
import univ.lille.infrastructure.adapter.security.JwtService;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class RegisterAdminUseCase implements RegisterAdminPort {

    private  final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService ;
    private final OrganizationRepository organizationRepository ;
    private final EmailPort emailPort;
   // private final ModuleServiceHelper moduleServiceHelper;



    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {

        String[] nameParts = NameUtils.splitFullName(request.getFullName());
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new EmailAlreadyExistsException("Email already in use : " + request.getEmail());
        }
        Organization organization =  Organization.builder()
                .name(request.getOrganizationName())
                .createdAt(LocalDateTime.now())
                .build();
        organization = organizationRepository.save(organization);

        //moduleServiceHelper.initializeModules(organization);

        User admin = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .firstName(nameParts[0])
                .lastName(nameParts[1])
                .organization(organization)
                .role(UserRole.ADMIN)
                .createdAt(LocalDateTime.now())
                .build();
        admin = userRepository.save(admin);

        emailPort.sendAdminWelcomeEmail(admin.getEmail(), admin.getFullName(), organization.getName());

        String token = jwtService.generateToken(admin);

        return new AuthResponse(token, admin.getEmail(), admin.getRole(), organization.getId());
    }
}
