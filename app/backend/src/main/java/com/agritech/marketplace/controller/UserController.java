package com.agritech.marketplace.controller;

import com.agritech.marketplace.dto.ApiResponse;
import com.agritech.marketplace.dto.LoginRequest;
import com.agritech.marketplace.dto.UserRegistrationRequest;
import com.agritech.marketplace.entity.User;
import com.agritech.marketplace.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Register New User
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse> registerUser(
            @Valid @RequestBody UserRegistrationRequest request) {

        try {

            User user = userService.register(request);

            user.setPassword(null);

            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("User registered successfully.", user));

        } catch (IllegalArgumentException ex) {

            return ResponseEntity
                    .badRequest()
                    .body(ApiResponse.error(ex.getMessage()));
        }
    }

    /**
     * Login User
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse> loginUser(
            @Valid @RequestBody LoginRequest request) {

        try {

            User user = userService.login(request);

            user.setPassword(null);

            return ResponseEntity.ok(
                    ApiResponse.ok("Login successful.", user)
            );

        } catch (IllegalArgumentException ex) {

            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(ex.getMessage()));
        }
    }

    /**
     * Get All Users
     */
    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {

        List<User> users = userService.findAll();

        users.forEach(user -> user.setPassword(null));

        return ResponseEntity.ok(users);
    }

    /**
     * Get User By Id
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getUserById(@PathVariable Long id) {

        try {

            User user = userService.findById(id);

            user.setPassword(null);

            return ResponseEntity.ok(user);

        } catch (IllegalArgumentException ex) {

            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(ex.getMessage()));
        }
    }

    /**
     * Health Check
     */
    @GetMapping("/health")
    public ResponseEntity<ApiResponse> health() {

        return ResponseEntity.ok(
                ApiResponse.ok("User Service is running.", null)
        );
    }

}
