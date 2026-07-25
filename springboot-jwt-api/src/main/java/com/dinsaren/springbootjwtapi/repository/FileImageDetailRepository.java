package com.dinsaren.springbootjwtapi.repository;


import com.dinsaren.springbootjwtapi.models.FileImageDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FileImageDetailRepository extends JpaRepository<FileImageDetail, Integer> {
    FileImageDetail findByFileNameAndStatus(String fileName, String status);
}
