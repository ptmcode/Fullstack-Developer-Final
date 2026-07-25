package com.dinsaren.springbootjwtapi.repository;

import com.dinsaren.springbootjwtapi.models.PostCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PostCategoryRepository extends JpaRepository<PostCategory, Integer> {
    List<PostCategory> findAllByStatus(String status);
    List<PostCategory> findAllByStatusIn(List<String> statusList);
    List<PostCategory> findAllByStatusInOrderByIdDesc(List<String> statusList);
    Optional<PostCategory> findByIdAndStatus(Integer id, String status);
}