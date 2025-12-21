
package univ.lille.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import univ.lille.enums.UserRole;
import univ.lille.enums.UserStatus;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@Builder
@NoArgsConstructor
public class User {
    private Long id;
    private String email;
    private String password;
    private String loginCode;

    //Admin
    private String fullName;

    //User
    private String firstName;
    private String lastName;

    private UserStatus userStatus;
    private UserRole role;
    private CustomRole customRole;
    private Organization organization;
    private LocalDateTime createdAt;
    private LocalDateTime lastLoginAt;
    private LocalDateTime lastAccessAt; 
    private String passwordResetToken;
    private LocalDateTime passwordResetTokenExpiry;

    private String profilePictureUrl;




    public boolean isInOrganization(Long orgId) {
        return organization != null && organization.getId() != null && organization.getId().equals(orgId);
    }

    public boolean hasCustomRole() {
        return customRole != null && customRole.getId() != null;
    }
    public String getDisplayName() {
        if (role == UserRole.ADMIN && fullName != null) {
            return fullName;
        }
        if (firstName != null && lastName != null) {
            return firstName + " " + lastName;
        }
        return email;
    }

    public boolean isAdmin() {
        return role == UserRole.ADMIN;
    }

    public boolean isActive() {
        return userStatus == UserStatus.ACTIVE;
    }

    public void activate() {
        this.userStatus = UserStatus.ACTIVE;
    }

    public void updateLastLogin() {
        this.lastLoginAt = LocalDateTime.now();
    }

    public void assignRole(CustomRole role) {
        if (role == null) {
            throw new IllegalArgumentException("CustomRole cannot be null");
        }

        if (organization != null && role.getOrgId() != null &&
                !organization.getId().equals(role.getOrgId())) {
            throw new AccessDeniedException("Role does not belong to the same organization");
        }

        this.customRole = role;
    }

    public void removeRole() {
        this.customRole = null;
    }

    public boolean hasRole(CustomRole role) {
        if (customRole == null || role == null) return false;
        return customRole.equals(role);
    }

    public boolean hasAnyAllowedRole(List<Long> allowedRoleIds) {
        if (customRole == null || allowedRoleIds == null) {
            return false;
        }
        return allowedRoleIds.contains(customRole.getId());
    }

    public boolean canAccessZone(Zone zone) {
        return zone.isAccessibleBy(this);
    }
}
