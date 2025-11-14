package univ.lille.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Zone {

    private Long id ;
    private String name ;
    private String description ;
    private String qrCode ;
    private Organization organization ;
    @Builder.Default
    private List<CustomRole> allowedRoles = new ArrayList<>();

    private LocalDateTime createdAt ;


    public boolean isAccessibleBy(User user) {
        if (user.isAdmin()) {
            return true;
        }
        if (allowedRoles.isEmpty()) {
            return false;
        }
    return user.hasAnyAllowedRole(allowedRoles);
    }
    public void addAllowedRole(CustomRole role) {
        if (!allowedRoles.contains(role)) {
            allowedRoles.add(role);
        }
    }

    public void removeAllowedRole(CustomRole role) {
        allowedRoles.remove(role);
    }


}
