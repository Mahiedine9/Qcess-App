package univ.lille.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank(message = "Email ne peut pas être vide")
    @Email(message= "Format d'email invalide")
    private String email ;

    @NotBlank(message = "Le mot de passe est obligatoire")
    @Size(min = 8, message = "Le mot de passe doit contenir au moins 8 caractères")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$",
            message = "Le mot de passe doit contenir au moins une lettre majuscule, une lettre minuscule, un chiffre et un caractère spécial")
    private String password ;

    @NotBlank(message = "Le nom de l'organisation est obligatoire")
    @Size(min = 2, max = 100, message = "Le nom de l'organisation doit contenir entre 2 et 100 caractères")
    private String organizationName ;
    @NotBlank(message = "Le nom complet est obligatoire")
    @Size(min = 2, max = 100, message = "Le nom complet doit contenir entre 2 et 100 caractères")
    private String fullName ;

}
