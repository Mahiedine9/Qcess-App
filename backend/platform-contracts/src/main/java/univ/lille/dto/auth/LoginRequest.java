package univ.lille.dto.auth;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {
    @NotBlank
    @Email
    private String email ;
    private String password ; //Pour admins
    private String loginCode ; //Pour users

    @AssertTrue(message = "Le mot de passe ou le code de connexion est obligatoire")
    public boolean isPasswordOrCodePresent() {
        return (password != null && !password.isBlank())
                || (loginCode != null && !loginCode.isBlank());
    }
}
