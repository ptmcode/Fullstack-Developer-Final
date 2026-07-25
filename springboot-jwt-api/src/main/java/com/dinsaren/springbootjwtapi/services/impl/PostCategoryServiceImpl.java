package com.dinsaren.springbootjwtapi.services.impl;

import com.dinsaren.springbootjwtapi.constants.Constants;
import com.dinsaren.springbootjwtapi.exception.AppException;
import com.dinsaren.springbootjwtapi.models.PostCategory;
import com.dinsaren.springbootjwtapi.models.User;
import com.dinsaren.springbootjwtapi.repository.PostCategoryRepository;
import com.dinsaren.springbootjwtapi.services.AuthenticationUtilService;
import com.dinsaren.springbootjwtapi.services.PostCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PostCategoryServiceImpl implements PostCategoryService {

    private final PostCategoryRepository postCategoryRepository;
    private final AuthenticationUtilService authenticationUtilService;

    @Override
    public List<PostCategory> findAllByStatus(String status) throws AppException {
        if ("ALL".equalsIgnoreCase(status)) {
            List<String> statuses = new ArrayList<>();
            statuses.add(Constants.STATUS_ACTIVE);
            statuses.add(Constants.STATUS_DELETE);
            return postCategoryRepository.findAllByStatusInOrderByIdDesc(statuses);
        }
        return postCategoryRepository.findAllByStatus(status);
    }

    @Override
    public PostCategory findById(Integer id) throws AppException {
        return postCategoryRepository.findById(id).orElse(null);
    }

    @Override
    public void save(PostCategory req) throws AppException {
        User user = authenticationUtilService.checkUser();
        req.setStatus(Constants.STATUS_ACTIVE);
        req.setCreateAt(new Date());
        req.setCreateBy(user.getUsername());
        postCategoryRepository.save(req);
    }

    @Override
    public void update(PostCategory req) throws AppException {
        PostCategory existing = findById(req.getId());
        User user = authenticationUtilService.checkUser();
        if (existing != null) {
            req.setStatus(Constants.STATUS_ACTIVE);
            req.setUpdateAt(new Date());
            req.setUpdateBy(user.getUsername());
            postCategoryRepository.save(req);
        }
    }

    @Override
    public void delete(PostCategory req) throws AppException {
        PostCategory existing = findById(req.getId());
        User user = authenticationUtilService.checkUser();
        if (existing != null) {
            req.setStatus(Constants.STATUS_DELETE);
            req.setUpdateAt(new Date());
            req.setUpdateBy(user.getUsername());
            postCategoryRepository.save(req);
        }
    }
}