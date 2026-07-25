package com.dinsaren.springbootjwtapi.services;

import com.dinsaren.springbootjwtapi.exception.AppException;
import com.dinsaren.springbootjwtapi.models.PostCategory;

import java.util.List;

public interface PostCategoryService {
    List<PostCategory> findAllByStatus(String status) throws AppException;
    PostCategory findById(Integer id) throws AppException;
    void save(PostCategory req) throws AppException;
    void update(PostCategory req) throws AppException;
    void delete(PostCategory req) throws AppException;
}