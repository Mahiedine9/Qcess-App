
package univ.lille.domain.model;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

class ZoneTest {

    @Test
    void isAccessibleBy_should_return_false_when_user_is_null() {
        Zone zone = Zone.builder()
                .allowedRoleIds(List.of(1L, 2L))
                .build();

        assertThat(zone.isAccessibleBy(null)).isFalse();
    }

    @Test
    void isAccessibleBy_should_return_true_for_admin_user() {
        User admin = mock(User.class);
        when(admin.isAdmin()).thenReturn(true);

        Zone zone = Zone.builder()
                .allowedRoleIds(List.of())
                .build();

        assertThat(zone.isAccessibleBy(admin)).isTrue();
    }

    @Test
    void isAccessibleBy_should_return_false_when_no_allowed_roles_and_user_not_admin() {
        User user = mock(User.class);
        when(user.isAdmin()).thenReturn(false);

        Zone zone = Zone.builder()
                .allowedRoleIds(List.of())
                .build();

        assertThat(zone.isAccessibleBy(user)).isFalse();
    }

    @Test
    void isAccessibleBy_should_return_true_when_user_has_allowed_role() {
        User user = mock(User.class);
        when(user.isAdmin()).thenReturn(false);
        when(user.hasAnyAllowedRole(List.of(1L, 2L))).thenReturn(true);

        Zone zone = Zone.builder()
                .allowedRoleIds(List.of(1L, 2L))
                .build();

        assertThat(zone.isAccessibleBy(user)).isTrue();
        verify(user).hasAnyAllowedRole(List.of(1L, 2L));
    }
        @Test
    void isActive_should_return_true_when_status_active() {
        Zone zone = Zone.builder().status(univ.lille.enums.ZoneStatus.ACTIVE).build();
        assertThat(zone.isActive()).isTrue();
        zone.setStatus(univ.lille.enums.ZoneStatus.INACTIVE);
        assertThat(zone.isActive()).isFalse();
    }

    @Test
    void isPublic_should_return_true_when_no_allowed_roles() {
        Zone zone = Zone.builder().allowedRoleIds(null).build();
        assertThat(zone.isPublic()).isTrue();
        zone.setAllowedRoleIds(List.of());
        assertThat(zone.isPublic()).isTrue();
        zone.setAllowedRoleIds(List.of(1L));
        assertThat(zone.isPublic()).isFalse();
    }

    @Test
    void isAllowedRole_should_return_true_if_role_in_list() {
        Zone zone = Zone.builder().allowedRoleIds(List.of(1L, 2L)).build();
        assertThat(zone.isAllowedRole(2L)).isTrue();
        assertThat(zone.isAllowedRole(99L)).isFalse();
        zone.setAllowedRoleIds(null);
        assertThat(zone.isAllowedRole(1L)).isFalse();
    }

    @Test
    void isAccessibleBy_should_return_false_when_user_has_no_allowed_role() {
        User user = mock(User.class);
        when(user.isAdmin()).thenReturn(false);
        when(user.hasAnyAllowedRole(List.of(1L, 2L))).thenReturn(false);

        Zone zone = Zone.builder()
                .allowedRoleIds(List.of(1L, 2L))
                .build();

        assertThat(zone.isAccessibleBy(user)).isFalse();
        verify(user).hasAnyAllowedRole(List.of(1L, 2L));
    }

    @Test
    void addAllowedRole_should_add_role_when_not_present() {
        Zone zone = Zone.builder()
                .allowedRoleIds(new java.util.ArrayList<>(List.of(1L)))
                .build();

        zone.addAllowedRole(2L);

        assertThat(zone.getAllowedRoleIds()).containsExactly(1L, 2L);
    }

    @Test
    void addAllowedRole_should_not_duplicate_existing_role() {
        Zone zone = Zone.builder()
                .allowedRoleIds(new java.util.ArrayList<>(List.of(1L, 2L)))
                .build();

        zone.addAllowedRole(2L);

        assertThat(zone.getAllowedRoleIds()).containsExactly(1L, 2L);
    }

    @Test
    void addAllowedRole_should_ignore_null_roleId() {
        Zone zone = Zone.builder()
                .allowedRoleIds(new java.util.ArrayList<>(List.of(1L)))
                .build();

        zone.addAllowedRole(null);

        assertThat(zone.getAllowedRoleIds()).containsExactly(1L);
    }

    @Test
    void removeAllowedRole_should_remove_role_when_present() {
        Zone zone = Zone.builder()
                .allowedRoleIds(new java.util.ArrayList<>(List.of(1L, 2L, 3L)))
                .build();

        zone.removeAllowedRole(2L);

        assertThat(zone.getAllowedRoleIds()).containsExactly(1L, 3L);
    }

    @Test
    void removeAllowedRole_should_ignore_null_roleId() {
        Zone zone = Zone.builder()
                .allowedRoleIds(new java.util.ArrayList<>(List.of(1L, 2L)))
                .build();

        zone.removeAllowedRole(null);

        assertThat(zone.getAllowedRoleIds()).containsExactly(1L, 2L);
    }

    @Test
    void removeAllowedRole_should_do_nothing_when_role_not_present() {
        Zone zone = Zone.builder()
                .allowedRoleIds(new java.util.ArrayList<>(List.of(1L, 2L)))
                .build();

        zone.removeAllowedRole(99L);

        assertThat(zone.getAllowedRoleIds()).containsExactly(1L, 2L);
    }
}
