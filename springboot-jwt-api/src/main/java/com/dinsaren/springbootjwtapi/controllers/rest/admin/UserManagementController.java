package com.dinsaren.springbootjwtapi.controllers.rest.admin;

import com.dinsaren.springbootjwtapi.constants.Constants;
import com.dinsaren.springbootjwtapi.models.Role;
import com.dinsaren.springbootjwtapi.models.User;
import com.dinsaren.springbootjwtapi.models.UserRole;
import com.dinsaren.springbootjwtapi.models.req.BasePostReq;
import com.dinsaren.springbootjwtapi.models.req.BaseUserReq;
import com.dinsaren.springbootjwtapi.payload.request.RegisterReq;
import com.dinsaren.springbootjwtapi.payload.response.MessageRes;
import com.dinsaren.springbootjwtapi.repository.RoleRepository;
import com.dinsaren.springbootjwtapi.repository.UserRepository;
import com.dinsaren.springbootjwtapi.services.AuthenticationUtilService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/app/admin/user")
@Slf4j
@Tag(name = "Admin - User Management", description = "Admin user management (ADMIN role required)")
@PreAuthorize("hasRole('ADMIN')")
public class UserManagementController {
    private final UserRepository userRepository;
    private final AuthenticationManager authenticationManager;
    private final AuthenticationUtilService authenticationUtilService;
    private final RoleRepository roleRepository;
    private MessageRes messageRes;
    private User user;
    private final PasswordEncoder encoder;

    public UserManagementController(UserRepository userRepository, AuthenticationManager authenticationManager, AuthenticationUtilService authenticationUtilService, RoleRepository roleRepository, PasswordEncoder encoder) {
        this.userRepository = userRepository;
        this.authenticationManager = authenticationManager;
        this.authenticationUtilService = authenticationUtilService;
        this.roleRepository = roleRepository;
        this.encoder = encoder;
    }

    @Operation(summary = "List all users", description = "Pass status=ALL to include deleted users")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "List returned successfully")
    })
    @PostMapping("/list")
    public ResponseEntity<MessageRes> getAllUser(@RequestBody BaseUserReq req) {
        messageRes = new MessageRes();
        List<User> userList = new ArrayList<>();
        try {
            user = authenticationUtilService.checkUser();
            log.info("Intercept get all users list req {}");
            if (null == user) {
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_GATEWAY);
            }
            if (req.getStatus().equals("ALL")) {
                userRepository.findAll().forEach(userList::add);
            } else {
                userRepository.findAllByStatus(req.getStatus()).forEach(userList::add);
            }
            messageRes.setMessageSuccess(userList);
        } catch (Throwable e) {
            log.info("While error get all users list", e);
        } finally {
            log.info("Final get all users response {}", messageRes);
        }
        return new ResponseEntity<>(messageRes, HttpStatus.OK);
    }

    @Operation(summary = "Create user account", description = "Admin creates a user with a specific role (USER or ADMIN)")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "User created successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error or duplicate username / email / phone")
    })
    @PostMapping("/create")
    public ResponseEntity<MessageRes> create(@RequestBody RegisterReq req) {
        MessageRes messageRes = new MessageRes();
        log.info("Intercept create account req {}", req);
        try {
            if (req.getFirstName().equals("") || req.getLastName().equals("") || req.getPhoneNumber().equals("") || req.getEmail().equals("") || req.getPassword().equals("") || null == req.getConfirmPassword() || "".equals(req.getConfirmPassword())) {
                messageRes.badRequest("");
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            if (!req.getConfirmPassword().equals(req.getPassword())) {
                messageRes.setConfirmPasswordNotMatch();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            if (userRepository.existsByUsernameAndStatus(req.getUsername(), Constants.STATUS_ACTIVE)) {
                messageRes.setNameAlreadyUse();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            if (userRepository.existsByEmailAndStatus(req.getEmail(), Constants.STATUS_ACTIVE)) {
                messageRes.setEmailAlreadyUse();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            if (userRepository.existsByPhoneNumberAndStatus(req.getPhoneNumber(), Constants.STATUS_ACTIVE)) {
                messageRes.setPhoneAlreadyUse();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            User user = new User(req.getUsername(), req.getEmail(), encoder.encode(req.getPassword()), req.getPhoneNumber());
            Set<Role> roles = new HashSet<>();
            Role role = null;
            if (req.getRole().equals(UserRole.ROLE_USER) || req.getRole().equals("USER")) {
                role = roleRepository.findByName(UserRole.ROLE_USER).orElseThrow(() -> new RuntimeException("Error: Role is not found."));
            }
            if (req.getRole().equals(UserRole.ROLE_ADMIN) || req.getRole().equals("ADMIN")) {
                role = roleRepository.findByName(UserRole.ROLE_ADMIN).orElseThrow(() -> new RuntimeException("Error: Role is not found."));
            }
            roles.add(role);
            user.setRoles(roles);
            user.setFirstName(req.getFirstName());
            user.setLastName(req.getLastName());
            user.setStatus(Constants.STATUS_ACTIVE);
            user.setChangePassword(Constants.No);
            user.setProfile(req.getProfile());
            user.setPassword(encoder.encode(req.getPassword()));
            userRepository.save(user);
            messageRes.setMessageCreateSuccess("User Open successfully!");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.info("Error open account req ", e);
            messageRes.internalServerError(null);
            return new ResponseEntity<>(messageRes, HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Open account req final result {}", messageRes);
        }
    }

    @Operation(summary = "Update user account")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Updated successfully"),
            @ApiResponse(responseCode = "400", description = "Duplicate username / email / phone or user not found")
    })
    @PostMapping("/update")
    public ResponseEntity<MessageRes> update(@RequestBody RegisterReq req) {
        MessageRes messageRes = new MessageRes();
        log.info("Intercept Update user account req {}", req);
        try {
            User user = userRepository.getById(req.getId());
            if (user.getUsername() == null) {
                messageRes.getUserNotFound();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            if (!user.getUsername().equals(req.getUsername())) {
                if (userRepository.existsByUsernameAndStatus(req.getUsername(), Constants.STATUS_ACTIVE)) {
                    messageRes.setNameAlreadyUse();
                    return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
                }
            }
            if (!user.getEmail().equals(req.getEmail())) {
                if (userRepository.existsByEmailAndStatus(req.getEmail(), Constants.STATUS_ACTIVE)) {
                    messageRes.setEmailAlreadyUse();
                    return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
                }
            }
            if (!user.getPhoneNumber().equals(req.getPhoneNumber())) {
                if (userRepository.existsByPhoneNumberAndStatus(req.getPhoneNumber(), Constants.STATUS_ACTIVE)) {
                    messageRes.setPhoneAlreadyUse();
                    return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
                }
            }
            user.setProfile(req.getProfile());
            user.setStatus(req.getStatus());
            user.setUsername(req.getUsername());
            user.setEmail(req.getEmail());
            user.setPhoneNumber(req.getPhoneNumber());
            user.setFirstName(req.getFirstName());
            user.setLastName(req.getLastName());
            Set<Role> roles = new HashSet<>();
            Role role = null;
            if (req.getRole().equals(UserRole.ROLE_USER) || req.getRole().equals("USER")) {
                role = roleRepository.findByName(UserRole.ROLE_USER).orElseThrow(() -> new RuntimeException("Error: Role is not found."));
            }
            if (req.getRole().equals(UserRole.ROLE_ADMIN) || req.getRole().equals("ADMIN")) {
                role = roleRepository.findByName(UserRole.ROLE_ADMIN).orElseThrow(() -> new RuntimeException("Error: Role is not found."));
            }
            if (!req.getPassword().equals(user.getPassword())) {
                user.setPassword(encoder.encode(req.getPassword()));
            }
            roles.add(role);
            user.setRoles(roles);
            userRepository.save(user);
            messageRes.setMessageCreateSuccess("Update User successfully!");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.info("Error Update user account req ", e);
            messageRes.internalServerError(null);
            return new ResponseEntity<>(messageRes, HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Update user account req final result {}", messageRes);
        }
    }

    @Operation(summary = "Get user by ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "User found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/{id}")
    public ResponseEntity<Object> getById(@RequestBody BasePostReq req, @PathVariable("id") Integer id) {
        try {
            MessageRes messageRes = new MessageRes();
            log.info("Intercept get user by req {}", req);
            List<String> statusList = new ArrayList<>();
            statusList.add("ACT");
            statusList.add("DEL");
            User userFind = userRepository.findByIdAndStatusIn(id, statusList);
            messageRes.setMessageSuccess(userFind);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.info("Error get user by id req ", e);
            messageRes.internalServerError(null);
            return new ResponseEntity<>(messageRes, HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Get user by id final result {}", messageRes);
        }
    }

    @Operation(summary = "Delete user", description = "Soft-deletes the user by setting status to DEL")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Deleted successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/delete")
    public ResponseEntity<MessageRes> delete(@RequestBody RegisterReq req) {
        MessageRes messageRes = new MessageRes();
        log.info("Intercept Update user account req {}", req);
        try {
            User user = userRepository.getById(req.getId());
            user.setStatus("DEL");
            userRepository.save(user);
            messageRes.setMessageCreateSuccess("Update User successfully!");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.info("Error Update user account req ", e);
            messageRes.internalServerError(null);
            return new ResponseEntity<>(messageRes, HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Update user account req final result {}", messageRes);
        }
    }
}