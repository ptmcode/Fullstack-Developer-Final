package com.school.management.security.service;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.school.management.common.constant.Status;
import com.school.management.user.User;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.Objects;
import java.util.Set;

@Getter
public class UserDetailsImpl implements UserDetails {

    private final Integer id;
    private final String username;
    private final String email;
    @JsonIgnore
    private final String password;
    private final boolean enabled;
    private final Collection<? extends GrantedAuthority> authorities;

    public UserDetailsImpl(Integer id, String username, String email, String password,
                           boolean enabled, Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.enabled = enabled;
        this.authorities = authorities;
    }

    /** Authorities = role names (ROLE_ADMIN, ...) + permission codes (student.create, ...). */
    public static UserDetailsImpl build(User user) {
        Set<GrantedAuthority> authorities = new LinkedHashSet<>();
        user.getRoles().forEach(role -> {
            authorities.add(new SimpleGrantedAuthority(role.getName()));
            role.getPermissions().forEach(p -> authorities.add(new SimpleGrantedAuthority(p.getCode())));
        });
        return new UserDetailsImpl(user.getId(), user.getUsername(), user.getEmail(),
                user.getPassword(), Status.ACTIVE.equals(user.getStatus()), authorities);
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        return Objects.equals(id, ((UserDetailsImpl) o).id);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(id);
    }
}
