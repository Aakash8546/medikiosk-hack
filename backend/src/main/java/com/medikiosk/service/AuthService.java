package com.medikiosk.service;

import com.medikiosk.exception.*;
import com.medikiosk.model.dto.request.*;
import com.medikiosk.model.dto.response.AuthResponse;
import com.medikiosk.model.entity.User;
import com.medikiosk.model.enums.RoleEnum;
import com.medikiosk.repository.UserRepository;
import com.medikiosk.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final AuditService auditService;

    public AuthResponse register(RegisterRequest req) {
        if (userRepo.existsByUsername(req.getUsername())) {
            throw new DuplicateResourceException("Username already exists");
        }

        RoleEnum role;
        try {
            role = RoleEnum.valueOf(req.getRole());
        } catch (IllegalArgumentException e) {
            throw new MediKioskException("Invalid role: " + req.getRole() + " — only PHYSICIAN accounts can be registered");
        }

        User user = User.builder()
            .username(req.getUsername())
            .passwordHash(passwordEncoder.encode(req.getPassword()))
            .fullName(req.getFullName())
            .role(role)
            .isActive(true)
            .build();

        user = userRepo.save(user);

        auditService.log("SYSTEM", user.getId(), "USER_REGISTERED",
            "users", user.getId(), null,
            Map.of("role", user.getRole().name()));

        return generateTokens(user);
    }

    public AuthResponse login(LoginRequest req) {
        User user = userRepo.findByUsername(req.getUsername())
            .orElseThrow(() -> new UnauthorizedException("Invalid credentials"));

        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Invalid credentials");
        }

        if (!user.getIsActive()) {
            throw new UnauthorizedException("Account is deactivated");
        }

        auditService.log(user.getRole().name(), user.getId(), "USER_LOGIN",
            "users", user.getId(), null, null);

        return generateTokens(user);
    }

    private AuthResponse generateTokens(User user) {
        String accessToken = tokenProvider.generateAccessToken(
            user.getId(), user.getUsername(), user.getRole().name());
        String refreshToken = tokenProvider.generateRefreshToken(user.getId());

        return AuthResponse.builder()
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .role(user.getRole().name())
            .fullName(user.getFullName())
            .expiresIn(3600)
            .build();
    }
}