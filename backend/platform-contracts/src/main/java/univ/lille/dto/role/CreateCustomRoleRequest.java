package univ.lille.dto.role;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateCustomRoleRequest {
    @NotBlank
    String name ;
    String description ;



}
