package univ.lille.dto.auth.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import univ.lille.enums.UserRole;

@Data
public class CreateUserRequest {
    @NotBlank
    @Email(message = "Email should be valid")
    private String email ;

    private  String firstName ;
    private  String lastName ;
    private UserRole role = UserRole.USER ;

}
