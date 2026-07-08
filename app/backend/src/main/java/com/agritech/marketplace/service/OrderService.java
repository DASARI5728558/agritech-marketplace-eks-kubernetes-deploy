package com.agritech.marketplace.service;

import com.agritech.marketplace.entity.Order;
import com.agritech.marketplace.entity.OrderItem;
import com.agritech.marketplace.entity.Product;
import com.agritech.marketplace.entity.User;
import com.agritech.marketplace.repository.OrderRepository;
import com.agritech.marketplace.repository.ProductRepository;
import com.agritech.marketplace.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    @Autowired
    public OrderService(OrderRepository orderRepository,
                         ProductRepository productRepository,
                         UserRepository userRepository) {
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Order placeOrder(Long buyerId, Map<Long, Integer> productQuantities) {
        User buyer = userRepository.findById(buyerId)
                .orElseThrow(() -> new IllegalArgumentException("Buyer not found: " + buyerId));

        Order order = new Order();
        order.setBuyer(buyer);
        BigDecimal total = BigDecimal.ZERO;

        for (Map.Entry<Long, Integer> entry : productQuantities.entrySet()) {
            Product product = productRepository.findById(entry.getKey())
                    .orElseThrow(() -> new IllegalArgumentException("Product not found: " + entry.getKey()));
            int qty = entry.getValue();
            if (product.getQuantityAvailable() < qty) {
                throw new IllegalArgumentException("Insufficient stock for product: " + product.getName());
            }
            product.setQuantityAvailable(product.getQuantityAvailable() - qty);
            productRepository.save(product);

            OrderItem item = new OrderItem();
            item.setOrder(order);
            item.setProduct(product);
            item.setQuantity(qty);
            item.setUnitPrice(product.getPrice());
            order.getItems().add(item);

            total = total.add(product.getPrice().multiply(BigDecimal.valueOf(qty)));
        }

        order.setTotalAmount(total);
        return orderRepository.save(order);
    }

    public List<Order> findByBuyer(Long buyerId) {
        return orderRepository.findByBuyerId(buyerId);
    }

    public Order findById(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + id));
    }

    public Order updateStatus(Long id, Order.OrderStatus status) {
        Order order = findById(id);
        order.setStatus(status);
        return orderRepository.save(order);
    }

    public List<Order> findAll() {
        return orderRepository.findAll();
    }
}
