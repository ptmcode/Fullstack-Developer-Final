package com.dinsaren.springbootjwtapi.repository;

import com.dinsaren.springbootjwtapi.models.Hotel;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HotelRepository extends JpaRepository<Hotel, Integer> {
  List<Hotel> findAllByStatusOrderByIdDesc(String status);
  Hotel findByIdAndStatus(Integer id, String status);
  List<Hotel> findAllByCategoryHotelIdAndStatusOrderByIdDesc(Integer categoryHotelId, String status);

}