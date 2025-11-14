package univ.lille.application.usecase.mapper;

import univ.lille.domain.model.User;
import univ.lille.dto.auth.user.UserDTO;
import univ.lille.enums.UserRole;

public class UserMapper {
    public static UserDTO toDTO (User user) {
        if(user == null ) return null;
        UserDTO userDTO = new UserDTO();
        userDTO.setId(user.getId());
        userDTO.setEmail(user.getEmail());
        if(user.getRole() == UserRole.ADMIN ) {
            userDTO.setFullName(user.getFullName());
        } else {
            userDTO.setFirstName(user.getFirstName());
            userDTO.setLastName(user.getLastName());
        }
        userDTO.setRole(user.getRole());
        userDTO.setUserStatus(user.getUserStatus());
        userDTO.setOrganisationId(user.getOrganization().getId());
        userDTO.setCreatedAt(user.getCreatedAt());

        return userDTO;
    }
}
