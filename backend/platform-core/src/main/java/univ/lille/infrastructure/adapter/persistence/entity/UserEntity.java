package univ.lille.infrastructure.adapter.persistence.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import univ.lille.enums.UserRole;
import univ.lille.enums.UserStatus;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false, unique = true)
    private String email;
    private String password;
    @Column(name = "login_code")
    private String loginCode;
    @Column(name = "full_name")
    private String fullName;
    @Column(name = "first_name")
    private String firstName;

    @Column(name = "last_name")
    private String lastName;
    @Enumerated(EnumType.STRING)
    @Column(name = "role")
    private UserRole role;
    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private UserStatus status;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organization_id")
    private OrganizationEntity organization;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "custom_role_id")
    private CustomRoleEntity customRole;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
    @Column(name = "last_login")
    private LocalDateTime lastLogin;

}
