package com.school.management.security.service;

import com.school.management.common.constant.Status;
import com.school.management.user.User;
import com.school.management.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String usernameOrEmail) throws UsernameNotFoundException {
        User user = userRepository.findByUsernameAndStatus(usernameOrEmail, Status.ACTIVE)
                .or(() -> userRepository.findByEmailAndStatus(usernameOrEmail, Status.ACTIVE))
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + usernameOrEmail));
        return UserDetailsImpl.build(user);
    }
}
