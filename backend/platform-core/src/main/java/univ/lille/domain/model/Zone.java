
package univ.lille.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import univ.lille.enums.ZoneStatus;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Zone {

    private Long id;
    private String name;
    private String description;

    private Long orgId;

    @Builder.Default
    private List<Long> allowedRoleIds = new ArrayList<>();

    private ZoneStatus status;
    private LocalDateTime createdAt;

    /**
     * Règle métier d'accès à la zone.
     * - Un ADMIN a toujours accès.
     * - Sinon, il faut au moins un rôle custom autorisé.
     */
    public boolean isAccessibleBy(User user) {
        if (user == null) {
            return false;
        }
        if (user.isAdmin()) {
            return true;
        }
        if (allowedRoleIds == null || allowedRoleIds.isEmpty()) {
            return false;
        }
        return user.hasAnyAllowedRole(allowedRoleIds);
    }
    public boolean isActive() {
        return status == ZoneStatus.ACTIVE;
    }

    public boolean isPublic() {
        return allowedRoleIds == null || allowedRoleIds.isEmpty();
    }

    public boolean isAllowedRole(Long roleId) {
        return allowedRoleIds != null && allowedRoleIds.contains(roleId);
    }
    public void addAllowedRole(Long roleId) {
        if (roleId != null && !allowedRoleIds.contains(roleId)) {
            allowedRoleIds.add(roleId);
        }
    }

    public void removeAllowedRole(Long roleId) {
        if (roleId == null) return;
        allowedRoleIds.removeIf(id -> id != null && id.equals(roleId));
    }
}
