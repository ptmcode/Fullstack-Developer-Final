package com.dinsaren.springbootjwtapi.repository;


import com.dinsaren.springbootjwtapi.models.Floor;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FloorRepository extends JpaRepository<Floor, Integer> {
  List<Floor> findAllByHotelIdAndStatus(Integer hotelId, String status);
}
