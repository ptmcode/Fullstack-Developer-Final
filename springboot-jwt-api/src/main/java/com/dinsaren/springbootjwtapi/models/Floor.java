package com.dinsaren.springbootjwtapi.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "floor", schema = "hotel")
public class Floor extends BaseEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(name = "hotel_id")
  private Integer hotelId;

  @Column(name = "number_no")
  private String numberNo;

  @Column(name = "decription") // Keep as-is if DB column is spelled this way
  private String decription;

  @Column(name = "status", length = 3)
  private String status;
  @Transient
  private List<Room> rooms;
}
