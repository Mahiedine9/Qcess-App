package univ.lille.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import univ.lille.enums.UserRole;
import univ.lille.enums.UserStatus;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@AllArgsConstructor
@Builder
@NoArgsConstructor
public class User {
    private Long id ;
    private String email ;
    private String password;
    private String loginCode ;

    //Admin
    private String fullName ;

    //User
    private String firstName ;
    private String lastName ;

    private UserStatus userStatus ;
    private UserRole role;
    private CustomRole customRole ;
    private Organization organization ;
    private LocalDateTime createdAt ;
    private LocalDateTime lastLoginAt ;
    @Builder.Default
    private List<CustomRole> customRoles = new ArrayList<>();
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

    public  void assignRole( CustomRole role) {
        if (!customRoles.contains(role)) {
            customRoles.add(role);
        }
    }
    public void removeRole( CustomRole role) {
        customRoles.remove(role);
    }
    public boolean hasRole(CustomRole role) {
        return customRoles.stream().anyMatch(r-> r.getName().equalsIgnoreCase(role.getName()));
    }
    public boolean hasAnyAllowedRole(List<CustomRole> allowedRoles) {
        return  customRoles.stream().anyMatch(allowedRoles::contains);

    }
    public boolean canAccessZone(Zone zone) {
        return zone.isAccessibleBy(this);
    }
}
