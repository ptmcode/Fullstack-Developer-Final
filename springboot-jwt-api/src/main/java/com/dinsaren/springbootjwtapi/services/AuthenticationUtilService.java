package com.dinsaren.springbootjwtapi.services;

import com.dinsaren.springbootjwtapi.constants.Constants;
import com.dinsaren.springbootjwtapi.constants.ErrorCode;
import com.dinsaren.springbootjwtapi.exception.AppException;
import com.dinsaren.springbootjwtapi.models.User;
import com.dinsaren.springbootjwtapi.repository.UserRepository;
import com.dinsaren.springbootjwtapi.security.services.UserDetailsImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@Slf4j
public class AuthenticationUtilService {
    private final UserRepository userRepository;

    public AuthenticationUtilService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User checkUser() throws AppException {
        log.info("Intercept get authentication");
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication instanceof AnonymousAuthenticationToken)) {
            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
            Optional<User> user = userRepository.findByPhoneNumberAndStatus(userDetails.getPhoneNumber(), Constants.STATUS_ACTIVE);
            if (user.isPresent()) {
                log.info("Get authentication success {}", authentication);
                return user.get();
            }
        }else {
            throw new AppException(HttpStatus.BAD_GATEWAY, ErrorCode.USER_NOT_PERMISSION, "User don't have permission");
        }

        return null;
    }

}
