package com.dinsaren.springbootjwtapi.controllers.rest;

import com.dinsaren.springbootjwtapi.caches.SmsCache;
import com.dinsaren.springbootjwtapi.constants.Constants;
import com.dinsaren.springbootjwtapi.exception.TokenRefreshException;
import com.dinsaren.springbootjwtapi.models.*;
import com.dinsaren.springbootjwtapi.models.req.ForgetPasswordReq;
import com.dinsaren.springbootjwtapi.models.req.RegisterInviteCodeReq;
import com.dinsaren.springbootjwtapi.models.req.RegisterVerifyReq;
import com.dinsaren.springbootjwtapi.models.res.UploadImageRes;
import com.dinsaren.springbootjwtapi.payload.request.LogOutReq;
import com.dinsaren.springbootjwtapi.payload.request.LoginReq;
import com.dinsaren.springbootjwtapi.payload.request.RegisterReq;
import com.dinsaren.springbootjwtapi.payload.request.TokenRefreshReq;
import com.dinsaren.springbootjwtapi.payload.response.JwtRes;
import com.dinsaren.springbootjwtapi.payload.response.MessageRes;
import com.dinsaren.springbootjwtapi.repository.OtpLogRepository;
import com.dinsaren.springbootjwtapi.repository.RoleRepository;
import com.dinsaren.springbootjwtapi.repository.UserRepository;
import com.dinsaren.springbootjwtapi.security.jwt.JwtUtils;
import com.dinsaren.springbootjwtapi.security.services.RefreshTokenService;
import com.dinsaren.springbootjwtapi.security.services.UserDetailsImpl;
import com.dinsaren.springbootjwtapi.services.OtpService;
import com.dinsaren.springbootjwtapi.services.UploadFileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/oauth")
@Slf4j
@Tag(name = "Authentication", description = "Login, register, token refresh and password management")
public class AuthController {
    private final UploadFileService uploadFileService;
    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder encoder;
    private final JwtUtils jwtUtils;
    private final RefreshTokenService refreshTokenService;
    private final OtpLogRepository otpLogRepository;
    @Value("${spring.otp.sms.enbaled}")
    private String otpEnable;
    private final OtpService otpService;
    private MessageRes messageRes;
    @Value("${spring.otp.sms.template}")
    protected String smsTemplate;
    @Value("${post.free.app.jwtExpirationMs}")
    private String expiredToken;

    public AuthController(UploadFileService uploadFileService, AuthenticationManager authenticationManager, UserRepository userRepository, RoleRepository roleRepository, PasswordEncoder encoder, JwtUtils jwtUtils, RefreshTokenService refreshTokenService, OtpLogRepository otpLogRepository, OtpService otpService) {
        this.uploadFileService = uploadFileService;
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.encoder = encoder;
        this.jwtUtils = jwtUtils;
        this.refreshTokenService = refreshTokenService;
        this.otpLogRepository = otpLogRepository;
        this.otpService = otpService;
    }

    private static String generateAccountNumber() {
        String accountNumber = "";
        try {
            Random rand = new Random();
            String card = "00";
            for (int i = 0; i < 10; i++) {
                int n = rand.nextInt(6) + 0;
                card += Integer.toString(n);
            }
            for (int i = 0; i < 12; i++) {
                if (i % 4 == 0) System.out.print("");
                System.out.print(card.charAt(i));
                accountNumber = "" + card.charAt(i);
            }
        } catch (Exception e) {
            accountNumber = "0000000034";
        }
        return accountNumber;
    }

    @Operation(summary = "Login", description = "Authenticate with phone number and password to receive a JWT access token")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Login successful, returns JWT tokens"),
            @ApiResponse(responseCode = "400", description = "Missing or invalid credentials"),
            @ApiResponse(responseCode = "401", description = "Invalid phone number or password")
    })
    @SecurityRequirements
    @PostMapping("/token")
    public ResponseEntity<?> authenticateUser(@RequestBody LoginReq req) {
        log.info("Intercept request oath token {}", req);
        MessageRes messageRes = new MessageRes();
        if (req.getPassword().equals("") || null == req.getPassword() || "".equals(req.getPassword()) || req.getPhoneNumber().equals("") || null == req.getPhoneNumber()) {
            messageRes.badRequest("Error: Invalid username and password");
            return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
        }
        try {
            Authentication authentication = authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(req.getPhoneNumber(), req.getPassword()));

            SecurityContextHolder.getContext().setAuthentication(authentication);

            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();

            String jwt = jwtUtils.generateJwtToken(userDetails);

            RefreshToken refreshToken = refreshTokenService.createRefreshToken(userDetails.getId());

            JwtRes jwtRes = new JwtRes();
            jwtRes.setExpiresIn(Integer.parseInt(expiredToken));
            jwtRes.setAccessToken(jwt);
            jwtRes.setRefreshToken(refreshToken.getToken());
            jwtRes.setTokenType(Constants.BEARER);
            Optional<User> findUser = userRepository.findByUsername(userDetails.getUsername());
            findUser.get().setPassword("******");
            findUser.ifPresent(jwtRes::setUser);
            return ResponseEntity.ok(jwtRes);
        } finally {
            log.info("While response oath token final result {}", messageRes);
        }
    }

    @Operation(summary = "Logout", description = "Invalidate the current refresh token")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Logout successful")
    })
    @PostMapping("/logout")
    public ResponseEntity<?> logoutUser(@RequestBody LogOutReq req) {
        refreshTokenService.deleteByUserId(req.getUserId());
        return ResponseEntity.ok(new MessageRes("Log out successful!", null));
    }

    private boolean checkStage(@RequestBody RegisterVerifyReq req, String key) {
        if (!StringUtils.hasLength(key)) {
            log.info("Invalid Stage {}", key);
            messageRes.setInvalidStage();
            return true;
        }
        boolean verify = otpService.verify(Integer.parseInt(req.getOtp()), key);
        if (!verify) {
            log.error("Verify OTP not match {}", req.getOtp());
            messageRes.setConfirmOTPNotMatch();
            return true;
        }
        return false;
    }

    private boolean checkStage(@RequestBody ForgetPasswordReq req, String key) {
        if (!StringUtils.hasLength(key)) {
            log.info("Invalid Stage {}", key);
            messageRes.setInvalidStage();
            return true;
        }
        boolean verify = otpService.verify(Integer.parseInt(req.getOtp()), key);
        if (!verify) {
            log.error("Verify OTP not match {}", req.getOtp());
            messageRes.setConfirmOTPNotMatch();
            return true;
        }
        return false;
    }

    private boolean checkStage(@RequestBody RegisterInviteCodeReq req, String key) {
        if (!StringUtils.hasLength(key)) {
            log.info("Invalid Stage {}", key);
            messageRes.setInvalidStage();
            return true;
        }
        boolean verify = otpService.verify(Integer.parseInt(req.getOtp()), key);
        if (!verify) {
            log.error("Verify OTP not match {}", req.getOtp());
            messageRes.setConfirmOTPNotMatch();
            return true;
        }
        return false;
    }

    @Operation(summary = "Forgot password - send OTP", description = "Send an OTP to the registered phone number to begin the password reset flow")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "OTP sent successfully"),
            @ApiResponse(responseCode = "502", description = "Phone number not found")
    })
    @SecurityRequirements
    @PostMapping("/forgot/password")
    public ResponseEntity<Object> forgotPassword(@RequestBody ForgetPasswordReq req) {
        try {
            messageRes = new MessageRes();
            Optional<User> user = userRepository.findByPhoneNumberAndStatus(req.getPhoneNumber(), Constants.STATUS_ACTIVE);
            if (!user.isPresent()) {
                messageRes.setDataNotFound();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_GATEWAY);
            }
            String key = req.getPhoneNumber() + req.getDeviceId();
            String otp = this.generateOtp(key);
            OtpLog otpLog = new OtpLog();
            otpLog.setToken(req.getPhoneNumber() + req.getDeviceId());
            otpLog.setSendTo(req.getPhoneNumber());
            otpLog.setStatus(Constants.STATUS_ACTIVE);
            Date date = new Date(System.currentTimeMillis());
            otpLog.setCreateAt(date);
            otpLog.setCreateBy(req.getPhoneNumber());
            otpLog.setOtp(otp);
            otpLog.setOtpMessage(otp + " " + smsTemplate);
            otpLogRepository.save(otpLog);
            messageRes.setOpenAccountSuccess();
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.info("Error open account req ", e);
            messageRes.internalServerError(null);
            return new ResponseEntity<>(messageRes, HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Verity OTP Open account req final result {}", messageRes);
        }
    }

    @Operation(summary = "Forgot password - verify OTP", description = "Verify the OTP received on the phone to proceed with password reset")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "OTP verified successfully"),
            @ApiResponse(responseCode = "400", description = "OTP does not match"),
            @ApiResponse(responseCode = "502", description = "Phone number not found")
    })
    @SecurityRequirements
    @PostMapping("/forgot/password/verify")
    public ResponseEntity<Object> forgotPasswordVerify(@RequestBody ForgetPasswordReq req) {
        try {
            messageRes = new MessageRes();
            Optional<User> userCheck = userRepository.findByPhoneNumberAndStatus(req.getPhoneNumber(), Constants.STATUS_ACTIVE);
            if (!userCheck.isPresent()) {
                messageRes.setInvalidStage();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_GATEWAY);
            }
            String key = req.getDeviceId() + req.getPhoneNumber();
            if (checkStage(req, key)) return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            SmsCache.remove(key);
            messageRes.setOpenAccountSuccess();
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.info("Error open account req ", e);
            messageRes.internalServerError(null);
            return new ResponseEntity<>(messageRes, HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Verity OTP Open account req final result {}", messageRes);
        }
    }

    @Operation(summary = "Forgot password - set new password", description = "Set a new password after OTP verification is complete")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Password changed successfully"),
            @ApiResponse(responseCode = "400", description = "Passwords do not match or old password is incorrect"),
            @ApiResponse(responseCode = "502", description = "User not found or invalid state")
    })
    @SecurityRequirements
    @PostMapping("/forgot/password/finish")
    public ResponseEntity<Object> forgotPasswordFinish(@RequestBody ForgetPasswordReq req) {
        try {
            messageRes = new MessageRes();
            if (!req.getPassword().equals(req.getConfirmPassword())) {
                messageRes.setConfirmPasswordNotMatch();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            Optional<User> userCheck = userRepository.findByPhoneNumberAndStatusAndChangePassword(req.getPhoneNumber(), Constants.STATUS_ACTIVE, Constants.YES);
            if (!userCheck.isPresent()) {
                messageRes.setInvalidStage();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_GATEWAY);
            }
            boolean checkPassword = encoder.matches(req.getOldPassword(), userCheck.get().getPassword());
            if (!checkPassword) {
                messageRes.setOldPasswordNotMatch();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            if (!userCheck.isPresent()) {
                messageRes.getUserNotFound();
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_GATEWAY);
            }
            userCheck.get().setPassword(encoder.encode(req.getPassword()));
            userCheck.get().setChangePassword(Constants.No);
            userRepository.save(userCheck.get());
            messageRes.setOpenAccountSuccess();
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.info("Error open account req ", e);
            messageRes.internalServerError(null);
            return new ResponseEntity<>(messageRes, HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Verity OTP Open account req final result {}", messageRes);
        }
    }

    @Operation(summary = "Register", description = "Create a new user account")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Account created successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error or duplicate username / email / phone")
    })
    @SecurityRequirements
    @PostMapping("/register")
    public ResponseEntity<MessageRes> registerUser(@RequestBody RegisterReq req) {
        MessageRes messageRes = new MessageRes();
        log.info("Intercept create account req {}", req);
        try {
            if (req.getFirstName().equals("") || req.getLastName().equals("") || req.getPhoneNumber().equals("") || req.getEmail().equals("") || req.getPassword().equals("") || null == req.getPassword() || null == req.getConfirmPassword() || "".equals(req.getPassword()) || "".equals(req.getConfirmPassword())) {
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
            roles.add(role);
            user.setRoles(roles);
            user.setFirstName(req.getFirstName());
            user.setLastName(req.getLastName());
            user.setStatus(Constants.STATUS_ACTIVE);
            user.setChangePassword(Constants.No);
            user.setProfile(req.getProfile());
            userRepository.save(user);
            messageRes.setMessageCreateSuccess("User Open Account successfully!");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.info("Error open account req ", e);
            messageRes.internalServerError(null);
            return new ResponseEntity<>(messageRes, HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Open account req final result {}", messageRes);
        }
    }

    @Operation(summary = "Refresh token", description = "Get a new access token using a valid refresh token")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "New access token issued"),
            @ApiResponse(responseCode = "403", description = "Refresh token expired or not found")
    })
    @SecurityRequirements
    @PostMapping("/refresh")
    public ResponseEntity<?> refreshToken(@RequestBody TokenRefreshReq request) {
        String requestRefreshToken = request.getRefreshToken();
        return refreshTokenService.findByToken(requestRefreshToken).map(refreshTokenService::verifyExpiration).map(RefreshToken::getUser).map(user -> {
            String token = jwtUtils.generateTokenFromUsername(user.getUsername());
            JwtRes jwtRes = new JwtRes();
            jwtRes.setExpiresIn(Integer.parseInt(expiredToken));
            jwtRes.setAccessToken(token);
            jwtRes.setRefreshToken(requestRefreshToken);
            jwtRes.setTokenType(Constants.BEARER);
            user.setPassword("******");
            jwtRes.setUser(user);
            return ResponseEntity.ok(jwtRes);
        }).orElseThrow(() -> new TokenRefreshException(requestRefreshToken, "Refresh token is not in database!"));
    }

    private String generateOtp(String key) {
        String otp = String.valueOf(otpService.generate(key));
        if (otpEnable.equals("Y")) {
            log.info("OTP IS : {}", otp);
        }
        SmsCache.add(key, otp);
        return otp;
    }

    private void validateStage(String stageKey) {
        String actionStage = SmsCache.get(stageKey);
        if (!StringUtils.hasLength(actionStage)) {
            log.info("Invalid Stage {}", stageKey);
        }
    }

    private void verifyOtp(String otpValue, String key) {
        boolean verify = otpService.verify(Integer.parseInt(otpValue), key);
        if (!verify) {
            log.error("Verify OTP not match {}", otpValue);
        }
    }

    @Operation(summary = "Upload profile image", description = "Upload an image file and get back the stored filename")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Image uploaded successfully"),
            @ApiResponse(responseCode = "500", description = "Upload failed")
    })
    @SecurityRequirements
    @PostMapping(value = "/image/upload", consumes = {"multipart/form-data"})
    public ResponseEntity<Object> uploadFile(@RequestParam("File") MultipartFile file) {
        log.info("Intercept upload file req {}", file.toString());
        try {
            UploadImageRes res = uploadFileService.uploadFile(file);
            messageRes = new MessageRes();
            messageRes.setMessageCreateSuccess(res);
            return ResponseEntity.ok(messageRes);
        } catch (Throwable e) {
            log.error("Error while upload file {}", e.getMessage());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Final Response upload file {}", file.getOriginalFilename());
        }
    }
}