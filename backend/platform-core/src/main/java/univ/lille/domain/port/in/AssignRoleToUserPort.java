package univ.lille.domain.port.in;

import univ.lille.dto.role.AssignRolesToUserRequest;

public interface AssignRoleToUserPort {
    void assignRoleTOUser(Long userId , AssignRolesToUserRequest request, Long organizationId);
}
