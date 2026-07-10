package com.agritech.marketplace.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
public class HomeController {

    @GetMapping("/")
    public Map<String, Object> home() {

        Map<String, Object> response = new LinkedHashMap<>();

        response.put("application", "AgriTech Marketplace Backend");
        response.put("version", "1.0.0");
        response.put("status", "Running");

        response.put("availableEndpoints", new String[]{
                "/api/users/register",
                "/api/users/login",
                "/api/products",
                "/api/orders",
                "/health"
        });

        return response;
    }

    @GetMapping("/health")
    public Map<String, String> health() {

        return Map.of(
                "status", "UP",
                "message", "Application is running successfully"
        );
    }

}
