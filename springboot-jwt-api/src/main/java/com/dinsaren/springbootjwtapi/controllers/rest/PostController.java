package com.dinsaren.springbootjwtapi.controllers.rest;

import com.dinsaren.springbootjwtapi.exception.AppException;
import com.dinsaren.springbootjwtapi.models.Post;
import com.dinsaren.springbootjwtapi.models.req.PostCreateReq;
import com.dinsaren.springbootjwtapi.models.req.PostUpdateReq;
import com.dinsaren.springbootjwtapi.models.res.MessageRes;
import com.dinsaren.springbootjwtapi.models.res.PageRes;
import com.dinsaren.springbootjwtapi.services.PostService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/app/post")
@Slf4j
@Tag(name = "Post", description = "Post content management")
//@PreAuthorize("hasRole('USER') or hasRole('CUSTOMER') or hasRole('ADMIN') or hasRole('MERCHANT') or hasRole('CREATOR')")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;

    @Operation(
            summary = "List posts with pagination",
            description = "Returns a paginated list of posts. Filter by status (ACT / DEL / ALL), categoryId, userId, or keyword search on title."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Page returned successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @GetMapping
    public ResponseEntity<MessageRes> list(
            @Parameter(description = "Page index (0-based)", example = "0")
            @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Number of items per page", example = "10")
            @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "Status filter: ACT | DEL | ALL", example = "ACT")
            @RequestParam(required = false, defaultValue = "ACT") String status,
            @Parameter(description = "Filter by category ID")
            @RequestParam(required = false) Integer categoryId,
            @Parameter(description = "Filter by author user ID")
            @RequestParam(required = false) Integer userId,
            @Parameter(description = "Search keyword in post title")
            @RequestParam(required = false) String keyword
    ) {
        MessageRes res = new MessageRes();
        try {
            PageRes<Post> data = postService.findAll(page, size, status, categoryId, userId, keyword);
            res.setSuccess(data);
            return ResponseEntity.ok(res);
        } catch (AppException e) {
            return ResponseEntity.status(e.getHttpStatus())
                    .body(new MessageRes(e.getErrorCode(), e.getMessage(), null));
        } catch (Exception e) {
            log.error("Error listing posts", e);
            res.setInternalServer();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(res);
        }
    }

    @Operation(summary = "Get post details by ID", description = "Increments view count on every call")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Post found"),
            @ApiResponse(responseCode = "404", description = "Post not found"),
            @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @GetMapping("/{id}")
    public ResponseEntity<MessageRes> getById(
            @Parameter(description = "Post ID", required = true)
            @PathVariable Integer id
    ) {
        MessageRes res = new MessageRes();
        try {
            Post post = postService.findById(id);
            res.setSuccess(post);
            return ResponseEntity.ok(res);
        } catch (AppException e) {
            return ResponseEntity.status(e.getHttpStatus())
                    .body(new MessageRes(e.getErrorCode(), e.getMessage(), null));
        } catch (Exception e) {
            log.error("Error getting post by id {}", id, e);
            res.setInternalServer();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(res);
        }
    }

    @Operation(summary = "Create post", description = "Creates a new post owned by the authenticated user")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Post created successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error or category not found"),
            @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @PostMapping
    public ResponseEntity<MessageRes> create(@Valid @RequestBody PostCreateReq req) {
        MessageRes res = new MessageRes();
        try {
            Post post = postService.create(req);
            res.setCreateSuccess(post);
            return ResponseEntity.status(HttpStatus.CREATED).body(res);
        } catch (AppException e) {
            return ResponseEntity.status(e.getHttpStatus())
                    .body(new MessageRes(e.getErrorCode(), e.getMessage(), null));
        } catch (Exception e) {
            log.error("Error creating post", e);
            res.setInternalServer();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(res);
        }
    }

    @Operation(summary = "Update post", description = "Updates title, description, image, and category of an existing post")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Updated successfully"),
            @ApiResponse(responseCode = "400", description = "Category not found"),
            @ApiResponse(responseCode = "404", description = "Post not found"),
            @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @PutMapping("/{id}")
    public ResponseEntity<MessageRes> update(
            @Parameter(description = "Post ID", required = true) @PathVariable Integer id,
            @Valid @RequestBody PostUpdateReq req
    ) {
        MessageRes res = new MessageRes();
        try {
            Post post = postService.update(id, req);
            res.setUpdateSuccess(post);
            return ResponseEntity.ok(res);
        } catch (AppException e) {
            return ResponseEntity.status(e.getHttpStatus())
                    .body(new MessageRes(e.getErrorCode(), e.getMessage(), null));
        } catch (Exception e) {
            log.error("Error updating post {}", id, e);
            res.setInternalServer();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(res);
        }
    }

    @Operation(summary = "Delete post", description = "Soft-deletes the post by setting its status to DEL")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Deleted successfully"),
            @ApiResponse(responseCode = "404", description = "Post not found"),
            @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<MessageRes> delete(
            @Parameter(description = "Post ID", required = true) @PathVariable Integer id
    ) {
        MessageRes res = new MessageRes();
        try {
            postService.delete(id);
            res.setUpdateSuccess("Post deleted successfully");
            return ResponseEntity.ok(res);
        } catch (AppException e) {
            return ResponseEntity.status(e.getHttpStatus())
                    .body(new MessageRes(e.getErrorCode(), e.getMessage(), null));
        } catch (Exception e) {
            log.error("Error deleting post {}", id, e);
            res.setInternalServer();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(res);
        }
    }
}