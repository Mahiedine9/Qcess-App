package univ.lille.dto.auth.user;

import lombok.Data;
import univ.lille.enums.UserRole;
import univ.lille.enums.UserStatus;

import java.time.LocalDateTime;

@Data
public class UserDTO {
    private  Long id ;
    private String email ;

    // pour Admin
    private String fullName ;
    // pour users
    private  String firstName ;
    private String lastName ;
    private UserRole role ;
    private UserStatus userStatus ;
    private Long organisationId ;
    private LocalDateTime createdAt ;

    public String getDisplayName() {
        if (role == UserRole.ADMIN) {
            return fullName;
        } else {
            return firstName + " " + lastName;
        }
    }
}
