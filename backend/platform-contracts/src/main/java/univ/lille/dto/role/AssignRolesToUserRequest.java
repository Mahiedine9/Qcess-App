package univ.lille.dto.role;

import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

@Data
public class AssignRolesToUserRequest {
    @NotEmpty
    private List<Long> roleIds ;

}
