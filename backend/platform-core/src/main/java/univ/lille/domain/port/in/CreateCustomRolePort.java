package univ.lille.domain.port.in;

import univ.lille.dto.role.CreateCustomRoleRequest;
import univ.lille.dto.role.CustomRoleDTO;

public interface CreateCustomRolePort {
    CustomRoleDTO createCustomRole(CreateCustomRoleRequest customRoleRequest,Long organizationId, Long adminId) ;

}
