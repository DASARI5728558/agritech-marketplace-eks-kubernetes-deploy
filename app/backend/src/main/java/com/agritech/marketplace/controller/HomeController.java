package com.agritech.marketplace.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
public class HomeController {

    @GetMapping("/")
    public Map<String, Object> home() {
        Map<String, Object> info = new LinkedHashMap<>();
        info.put("service", "agritech-marketplace-backend");
        info.put("status", "UP");
        info.put("endpoints", new String[]{
                "/api/users/register",
                "/api/users/login",
                "/api/products",
                "/api/orders"
        });
        return info;
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "OK");
    }
}
