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
@Table(name = "room", schema = "hotel")
public class Room extends BaseEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(name = "floor_id")
  private Integer floorId;

  @Column(name = "number_no")
  private String numberNo;

  @Column(name = "decription") // Keep if DB column is actually named this way
  private String decription;

  @Column(name = "price", precision = 12, scale = 4)
  private BigDecimal price;

  @Column(name = "status", length = 3)
  private String status;
}
