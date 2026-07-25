package com.dinsaren.springbootjwtapi.models;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "book_room", schema = "hotel")
public class BookRoom extends BaseEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(name = "hotel_id")
  private Integer hotelId;

  @Column(name = "customer_id")
  private Integer customerId;

  @Column(name = "date")
  private LocalDateTime date;

  @Column(name = "checkin_date")
  private LocalDateTime checkinDate;

  @Column(name = "checkout_date")
  private LocalDateTime checkoutDate;

  @Column(name = "total_price", precision = 12, scale = 4)
  private BigDecimal totalPrice;

  @Column(name = "status", length = 3)
  private String status;
}
