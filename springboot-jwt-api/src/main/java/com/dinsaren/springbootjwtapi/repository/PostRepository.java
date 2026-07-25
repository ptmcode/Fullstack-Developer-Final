package com.dinsaren.springbootjwtapi.repository;

import com.dinsaren.springbootjwtapi.models.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PostRepository extends JpaRepository<Post, Integer> {

    Page<Post> findAllByStatusOrderByIdDesc(String status, Pageable pageable);

    Page<Post> findAllByStatusInOrderByIdDesc(List<String> statusList, Pageable pageable);

    Page<Post> findAllByStatusInAndPostCategory_IdOrderByIdDesc(List<String> statusList, Integer categoryId, Pageable pageable);

    Page<Post> findAllByStatusAndUser_IdOrderByIdDesc(String status, Integer userId, Pageable pageable);

    Page<Post> findByStatusAndUser_IdAndPostCategory_IdOrderByIdDesc(String status, Integer userId, Integer categoryId, Pageable pageable);

    Page<Post> findByTitleContainingIgnoreCaseAndStatusOrderByIdDesc(String keyword, String status, Pageable pageable);

    Optional<Post> findByIdAndStatus(Integer id, String status);

    Optional<Post> findById(Integer id);
}