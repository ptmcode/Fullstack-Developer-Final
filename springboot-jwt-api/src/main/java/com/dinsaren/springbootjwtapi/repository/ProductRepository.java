package com.dinsaren.springbootjwtapi.repository;

import com.dinsaren.springbootjwtapi.models.product.Product;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepository extends JpaRepository<Product, Integer> {
    List<Product> findAllByCategory_Id(int categoryId);
    List<Product> findAllByStatusInOrderByIdDesc(List<String> statuses);
}
