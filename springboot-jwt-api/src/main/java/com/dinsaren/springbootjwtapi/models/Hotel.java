package com.dinsaren.springbootjwtapi.models;


import com.dinsaren.springbootjwtapi.constants.Constants;
import com.dinsaren.springbootjwtapi.models.req.CreateHotelRequest;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "hotel", schema = "hotel")
public class Hotel extends BaseEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(name = "user_id")
  private Integer userId;

  @Column(name = "image_url")
  private String imageUrl;

  @Column(name = "name")
  private String name;

  @Column(name = "decription") // Keep as-is if your DB column is actually "decription"
  private String decription;

  @Column(name = "phone", length = 22)
  private String phone;

  @Column(name = "email", length = 22)
  private String email;

  @Column(name = "status", length = 3)
  private String status;
  @Transient
  private List<Floor> floors;

  @ManyToOne
  private CategoryHotel categoryHotel;

  public void setDataCreate(CreateHotelRequest data, CategoryHotel categoryHotel) {
      this.id = data.getId();
      this.userId = data.getUserId();
      this.imageUrl = data.getImageUrl();
      this.name = data.getName();
      this.decription = data.getDescription();
      this.phone = data.getPhone();
      this.email = data.getEmail();
      this.status = Constants.STATUS_ACTIVE;
      this.categoryHotel = categoryHotel;
  }
}
