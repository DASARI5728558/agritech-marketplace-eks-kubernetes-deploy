package com.agritech.marketplace.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "products")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Product name is required")
    @Column(nullable = false, length = 150)
    private String name;

    @Column(length = 500)
    private String description;

    @NotBlank(message = "Category is required")
    @Column(nullable = false, length = 60)
    private String category;

    @Positive(message = "Price must be positive")
    @Column(nullable = false)
    private BigDecimal price;

    @Positive(message = "Quantity must be positive")
    @Column(nullable = false)
    private Integer quantityAvailable;

    @Column(nullable = false, length = 20)
    private String unit = "kg";

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_id", nullable = false)
    private User farmer;

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
