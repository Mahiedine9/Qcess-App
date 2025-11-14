package univ.lille.application.usecase;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import univ.lille.application.service.AuthenticationService;


import org.springframework.stereotype.Service;
import univ.lille.application.usecase.mapper.UserMapper;
import univ.lille.application.utils.NameUtils;
import univ.lille.domain.exception.EmailAlreadyExistsException;
import univ.lille.domain.exception.OrganizationNotFoundException;
import univ.lille.domain.model.Organization;
import univ.lille.domain.model.User;
import univ.lille.domain.port.in.CreateUserPort;
import univ.lille.domain.port.out.EmailPort;
import univ.lille.domain.port.out.OrganizationRepository;
import univ.lille.domain.port.out.UserRepository;
import univ.lille.dto.auth.user.CreateUserRequest;
import univ.lille.dto.auth.user.UserDTO;
import univ.lille.enums.UserStatus;
import univ.lille.infrastructure.utils.CodeGenerator;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class CreateUserUseCase  implements CreateUserPort {

    private final UserRepository userRepository;
    private final OrganizationRepository organizationRepository;
    private final EmailPort emailPort;
    private final AuthenticationService authenticationService;


    @Override
    @Transactional
    public UserDTO createUser(CreateUserRequest createUserRequest) {
        Long organizationId = authenticationService.getCurrentUserOrganizationId();
        Long adminId = authenticationService.getCurrentUserId();
        String fullName = NameUtils.buildFullName(
                createUserRequest.getFirstName(),
                createUserRequest.getLastName()
        );

        Organization org = organizationRepository.findById(organizationId)
                .orElseThrow(() -> new OrganizationNotFoundException(
                        "Organization not found with ID: " + organizationId
                ));

        if (userRepository.existsByEmail(createUserRequest.getEmail())) {
            throw new EmailAlreadyExistsException(
                    "Email already exists: " + createUserRequest.getEmail()
            );
        }

        String loginCode = CodeGenerator.generateLoginCode();
        User user = User.builder()
                .email(createUserRequest.getEmail())
                .fullName(fullName)
                .firstName(createUserRequest.getFirstName())
                .lastName(createUserRequest.getLastName())
                .role(createUserRequest.getRole())
                .loginCode( loginCode)
                .userStatus(UserStatus.PENDING)
                .organization(org)
                .createdAt(LocalDateTime.now())
                .build();
        user = userRepository.save(user);

        emailPort.sendWelcomeEmail(user.getEmail(), user.getFullName(), loginCode);
        return UserMapper.toDTO(user);


    }
}
