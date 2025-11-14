package univ.lille.domain.port.in;

import univ.lille.dto.auth.AuthResponse;
import univ.lille.dto.auth.RegisterRequest;

public interface RegisterAdminPort {
    AuthResponse register (RegisterRequest request);


}
