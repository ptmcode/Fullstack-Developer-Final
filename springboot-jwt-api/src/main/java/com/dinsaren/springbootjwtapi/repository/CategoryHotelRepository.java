package com.dinsaren.springbootjwtapi.repository;

import com.dinsaren.springbootjwtapi.models.CategoryHotel;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryHotelRepository extends JpaRepository<CategoryHotel, Integer> {
  List<CategoryHotel> findAllByStatus(String string);
}
