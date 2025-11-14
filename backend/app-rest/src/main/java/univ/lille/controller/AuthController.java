package univ.lille.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import univ.lille.application.usecase.LoginUseCase;
import univ.lille.application.usecase.LogoutUseCase;
import univ.lille.application.usecase.RegisterAdminUseCase;
import univ.lille.dto.auth.AuthResponse;
import univ.lille.dto.auth.LoginRequest;
import univ.lille.dto.auth.RegisterRequest;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private final RegisterAdminUseCase registerAdminUseCase;
    private final LoginUseCase loginUseCase;
    private final LogoutUseCase logoutUseCase;
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {

        AuthResponse res = registerAdminUseCase.register(request);
        return ResponseEntity.ok(res);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest loginRequest) {
        AuthResponse res = loginUseCase.login(loginRequest);
        return ResponseEntity.ok(res);

    }


    @PostMapping("/logout")
    public ResponseEntity<String> logout(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest().body("Invalid token");
        }
        String jwt = authHeader.substring(7);
        logoutUseCase.logout(jwt);
        return ResponseEntity.ok("Logged out successfully");
    }

    /**
     * Test si le token est valide
     */
    @GetMapping("/me")
    public ResponseEntity<String> getCurrentUser() {
        return ResponseEntity.ok("Authenticated");
    }


}
