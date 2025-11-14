package univ.lille.domain.port.in;

import univ.lille.dto.auth.user.CreateUserRequest;
import univ.lille.dto.auth.user.UserDTO;

public interface CreateUserPort {
    UserDTO createUser(CreateUserRequest createUserRequest);
}
