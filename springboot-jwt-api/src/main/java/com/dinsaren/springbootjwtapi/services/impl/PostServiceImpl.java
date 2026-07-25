package com.dinsaren.springbootjwtapi.services.impl;

import com.dinsaren.springbootjwtapi.constants.Constants;
import com.dinsaren.springbootjwtapi.exception.AppException;
import com.dinsaren.springbootjwtapi.models.Post;
import com.dinsaren.springbootjwtapi.models.PostCategory;
import com.dinsaren.springbootjwtapi.models.User;
import com.dinsaren.springbootjwtapi.models.notification.Notification;
import com.dinsaren.springbootjwtapi.models.notification.NotificationData;
import com.dinsaren.springbootjwtapi.models.notification.PushNotificationRequest;
import com.dinsaren.springbootjwtapi.models.req.PostCreateReq;
import com.dinsaren.springbootjwtapi.models.req.PostUpdateReq;
import com.dinsaren.springbootjwtapi.models.res.PageRes;
import com.dinsaren.springbootjwtapi.repository.PostCategoryRepository;
import com.dinsaren.springbootjwtapi.repository.PostRepository;
import com.dinsaren.springbootjwtapi.services.AuthenticationUtilService;
import com.dinsaren.springbootjwtapi.services.PostService;
import com.dinsaren.springbootjwtapi.services.PushNotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PostServiceImpl implements PostService {

    private final PushNotificationService pushNotificationService;
    private final PostRepository postRepository;
    private final AuthenticationUtilService authenticationUtilService;
    private final PostCategoryRepository postCategoryRepository;

    @Override
    public PageRes<Post> findAll(int page, int size, String status, Integer categoryId, Integer userId, String keyword) throws AppException {
        Pageable pageable = PageRequest.of(page, size);
        Page<Post> result;

        if (keyword != null && !keyword.isBlank()) {
            String effectiveStatus = (status == null || status.isBlank()) ? Constants.STATUS_ACTIVE : status;
            result = postRepository.findByTitleContainingIgnoreCaseAndStatusOrderByIdDesc(keyword, effectiveStatus, pageable);
            return PageRes.of(result);
        }

        boolean hasUser = userId != null && userId > 0;
        boolean hasCategory = categoryId != null && categoryId > 0;
        boolean isAll = "ALL".equalsIgnoreCase(status);
        List<String> allStatuses = Arrays.asList(Constants.STATUS_ACTIVE, Constants.STATUS_DELETE);

        if (hasUser) {
            if (hasCategory) {
                result = postRepository.findByStatusAndUser_IdAndPostCategory_IdOrderByIdDesc(
                        isAll ? Constants.STATUS_ACTIVE : status, userId, categoryId, pageable);
            } else {
                result = postRepository.findAllByStatusAndUser_IdOrderByIdDesc(
                        isAll ? Constants.STATUS_ACTIVE : status, userId, pageable);
            }
        } else if (isAll) {
            result = hasCategory
                    ? postRepository.findAllByStatusInAndPostCategory_IdOrderByIdDesc(allStatuses, categoryId, pageable)
                    : postRepository.findAllByStatusInOrderByIdDesc(allStatuses, pageable);
        } else {
            String effectiveStatus = (status == null || status.isBlank()) ? Constants.STATUS_ACTIVE : status;
            result = postRepository.findAllByStatusOrderByIdDesc(effectiveStatus, pageable);
        }

        return PageRes.of(result);
    }

    @Override
    public Post findById(Integer id) throws AppException {
        Post post = postRepository.findByIdAndStatus(id, Constants.STATUS_ACTIVE)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "ERR-404", "Post not found"));
        post.setViews(post.getViews() + 1);
        postRepository.saveAndFlush(post);
        return post;
    }

    @Override
    public Post create(PostCreateReq req) throws AppException {
        User user = authenticationUtilService.checkUser();
        PostCategory postCategory = postCategoryRepository.findById(req.getCategoryId())
                .orElseThrow(() -> new AppException(HttpStatus.BAD_REQUEST, "ERR-400", "Post category not found"));

        Post post = new Post();
        post.setTitle(req.getTitle());
        post.setDescription(req.getDescription());
        post.setBody(req.getBody());
        post.setImage(req.getImage());
        post.setTags(req.getTags());
        post.setPostCategory(postCategory);
        post.setUser(user);
        post.setStatus(Constants.STATUS_ACTIVE);
        post.setCreateAt(new Date());
        post.setCreateBy(user.getUsername());

        Post saved = postRepository.save(post);
        sendPushNotification(saved);
        return saved;
    }

    @Override
    public Post update(Integer id, PostUpdateReq req) throws AppException {
        User user = authenticationUtilService.checkUser();
        Post post = postRepository.findByIdAndStatus(id, Constants.STATUS_ACTIVE)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "ERR-404", "Post not found"));
        PostCategory postCategory = postCategoryRepository.findById(req.getCategoryId())
                .orElseThrow(() -> new AppException(HttpStatus.BAD_REQUEST, "ERR-400", "Post category not found"));

        post.setTitle(req.getTitle());
        post.setDescription(req.getDescription());
        post.setBody(req.getBody());
        post.setImage(req.getImage());
        post.setTags(req.getTags());
        post.setPostCategory(postCategory);
        post.setUpdateAt(new Date());
        post.setUpdateBy(user.getUsername());

        return postRepository.save(post);
    }

    @Override
    public void delete(Integer id) throws AppException {
        User user = authenticationUtilService.checkUser();
        Post post = postRepository.findByIdAndStatus(id, Constants.STATUS_ACTIVE)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "ERR-404", "Post not found"));
        post.setStatus(Constants.STATUS_DELETE);
        post.setUpdateAt(new Date());
        post.setUpdateBy(user.getUsername());
        postRepository.save(post);
    }

    @Override
    public Post like(Integer id) throws AppException {
        Post post = postRepository.findByIdAndStatus(id, Constants.STATUS_ACTIVE)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "ERR-404", "Post not found"));
        post.getReactions().setLikes(post.getReactions().getLikes() + 1);
        return postRepository.save(post);
    }

    @Override
    public Post dislike(Integer id) throws AppException {
        Post post = postRepository.findByIdAndStatus(id, Constants.STATUS_ACTIVE)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "ERR-404", "Post not found"));
        post.getReactions().setDislikes(post.getReactions().getDislikes() + 1);
        return postRepository.save(post);
    }

    private void sendPushNotification(Post post) {
        PushNotificationRequest request = new PushNotificationRequest();
        request.setTo("/topics/FREE_POST_APP");
        Notification notification = new Notification();
        notification.setTitle(post.getTitle());
        notification.setBody(post.getDescription());
        notification.setSound("default");
        NotificationData data = new NotificationData();
        data.setImageUrl(post.getImage());
        data.setPostId(post.getId().toString());
        request.setData(data);
        request.setNotification(notification);
        pushNotificationService.sendPushNotification(request);
    }
}