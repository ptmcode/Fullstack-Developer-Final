package com.dinsaren.springbootjwtapi.models;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "book_room_item", schema = "hotel")
public class BookRoomItem extends BaseEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(name = "book_room_id")
  private Integer bookRoomId;

  @Column(name = "room_id")
  private Integer roomId;

  @Column(name = "price", precision = 12, scale = 4)
  private BigDecimal price;

  @Column(name = "qty", precision = 12, scale = 4)
  private BigDecimal qty;

  @Column(name = "status", length = 3)
  private String status;
}
