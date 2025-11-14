package univ.lille.domain.port.in;

import univ.lille.dto.auth.AuthResponse;
import univ.lille.dto.auth.LoginRequest;

public interface LoginUserPort {
    AuthResponse login (LoginRequest request);

}
