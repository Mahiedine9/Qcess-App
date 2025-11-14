package univ.lille.infrastructure.adapter.security;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;

@Getter
public class QcessUserPrincipal implements UserDetails {

    private final Long id;
    private final Long organizationId;
    private final String email;
    private final String password;
    private final Collection<? extends GrantedAuthority> authorities;

    public QcessUserPrincipal(
            Long id,
            Long organizationId,
            String email,
            String password,
            Collection<? extends GrantedAuthority> authorities
    ) {
        this.id = id;
        this.organizationId = organizationId;
        this.email = email;
        this.password = password;
        this.authorities = authorities;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override public boolean isAccountNonExpired() { return true; }
    @Override public boolean isAccountNonLocked() { return true; }
    @Override public boolean isCredentialsNonExpired() { return true; }
    @Override public boolean isEnabled() { return true; }
}
