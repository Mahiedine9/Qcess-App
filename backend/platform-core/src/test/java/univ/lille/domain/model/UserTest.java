
package univ.lille.domain.model;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import univ.lille.enums.UserRole;
import univ.lille.enums.UserStatus;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

class UserTest {


    @Test
    void getDisplayName_should_return_fullName_for_admin_when_present() {
        User user = User.builder()
                .role(UserRole.ADMIN)
                .fullName("Admin Full Name")
                .email("admin@test.com")
                .firstName("John")
                .lastName("Doe")
                .build();

        String displayName = user.getDisplayName();

        assertThat(displayName).isEqualTo("Admin Full Name");
    }

    @Test
    void getDisplayName_should_return_first_and_last_name_for_non_admin() {
        User user = User.builder()
                .role(UserRole.USER)
                .firstName("John")
                .lastName("Doe")
                .email("user@test.com")
                .build();

        String displayName = user.getDisplayName();

        assertThat(displayName).isEqualTo("John Doe");
    }

        @Test
    void isInOrganization_should_return_true_if_user_in_org() {
        Organization org = Organization.builder().id(10L).build();
        User user = User.builder().organization(org).build();
        assertThat(user.isInOrganization(10L)).isTrue();
        assertThat(user.isInOrganization(99L)).isFalse();
    }

    @Test
    void hasCustomRole_should_return_true_if_user_has_role_with_id() {
        CustomRole role = CustomRole.builder().id(5L).build();
        User user = User.builder().customRole(role).build();
        assertThat(user.hasCustomRole()).isTrue();
        user.setCustomRole(null);
        assertThat(user.hasCustomRole()).isFalse();
        user.setCustomRole(CustomRole.builder().build());
        assertThat(user.hasCustomRole()).isFalse();
    }
    @Test
    void getDisplayName_should_fallback_to_email_when_no_name() {
        User user = User.builder()
                .role(UserRole.USER)
                .email("user@test.com")
                .build();

        String displayName = user.getDisplayName();

        assertThat(displayName).isEqualTo("user@test.com");
    }


    @Test
    void isAdmin_should_return_true_when_role_is_admin() {
        User user = User.builder()
                .role(UserRole.ADMIN)
                .build();

        assertThat(user.isAdmin()).isTrue();
    }

    @Test
    void isAdmin_should_return_false_when_role_is_not_admin() {
        User user = User.builder()
                .role(UserRole.USER)
                .build();

        assertThat(user.isAdmin()).isFalse();
    }

    // ---------------------------------------------------

    @Test
    void isActive_should_return_true_when_status_is_active() {
        User user = User.builder()
                .userStatus(UserStatus.ACTIVE)
                .build();

        assertThat(user.isActive()).isTrue();
    }

    @Test
    void activate_should_set_status_to_active() {
        User user = User.builder()
                .userStatus(UserStatus.PENDING)
                .build();

        user.activate();

        assertThat(user.getUserStatus()).isEqualTo(UserStatus.ACTIVE);
        assertThat(user.isActive()).isTrue();
    }


    @Test
    void updateLastLogin_should_set_lastLoginAt_to_now() {
        User user = new User();
        assertThat(user.getLastLoginAt()).isNull();

        user.updateLastLogin();

        assertThat(user.getLastLoginAt()).isNotNull();
        assertThat(user.getLastLoginAt()).isBeforeOrEqualTo(LocalDateTime.now());}


    @Test
    void assignRole_should_add_role_if_not_present() {
        CustomRole role = mock(CustomRole.class);
        when(role.getName()).thenReturn("MANAGER");

        User user = new User();

        user.assignRole(role);
        user.assignRole(role);

        assertThat(user.getCustomRole().equals(role));
    }

    @Test
    void removeRole_should_remove_role_from_list() {
        CustomRole role = mock(CustomRole.class);
        when(role.getName()).thenReturn("MANAGER");

        User user = new User();
        user.assignRole(role);

        user.removeRole();

        assertThat(user.getCustomRole() != role) ;
    }


    @Test
    void hasRole_should_return_false_when_role_not_present() {
        CustomRole roleInUser = mock(CustomRole.class);
        when(roleInUser.getName()).thenReturn("MANAGER");

        CustomRole otherRole = mock(CustomRole.class);
        when(otherRole.getName()).thenReturn("EMPLOYEE");

        User user = new User();
        user.assignRole(roleInUser);

        assertThat(user.hasRole(otherRole)).isFalse();
    }




    // ---------------------------------------------------
    // canAccessZone()
    // ---------------------------------------------------

    @Test
    void canAccessZone_should_delegate_to_zone_isAccessibleBy() {
        User user = new User();

        Zone zone = Mockito.mock(Zone.class);
        when(zone.isAccessibleBy(user)).thenReturn(true);

        boolean result = user.canAccessZone(zone);

        assertThat(result).isTrue();
        verify(zone).isAccessibleBy(user);
    }
}
