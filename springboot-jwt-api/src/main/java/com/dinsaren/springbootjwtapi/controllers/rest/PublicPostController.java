package com.dinsaren.springbootjwtapi.controllers.rest;

import com.dinsaren.springbootjwtapi.exception.AppException;
import com.dinsaren.springbootjwtapi.models.Post;
import com.dinsaren.springbootjwtapi.models.res.MessageRes;
import com.dinsaren.springbootjwtapi.models.res.PageRes;
import com.dinsaren.springbootjwtapi.services.PostService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/public/post")
@Slf4j
@Tag(name = "Public - Post", description = "Public access to posts with like/dislike (no auth required)")
@SecurityRequirements
@RequiredArgsConstructor
public class PublicPostController {

    private final PostService postService;

    @Operation(
        summary = "List posts (paginated)",
        description = "Retrieve posts with optional filters. All parameters are optional."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Page returned successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @GetMapping
    public ResponseEntity<MessageRes> list(
            @Parameter(description = "Page number (0-based)") @RequestParam(defaultValue = "0")  int page,
            @Parameter(description = "Page size")             @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "Status filter: ACT / DEL / ALL") @RequestParam(defaultValue = "ACT") String status,
            @Parameter(description = "Filter by category ID") @RequestParam(required = false) Integer categoryId,
            @Parameter(description = "Filter by user ID")     @RequestParam(required = false) Integer userId,
            @Parameter(description = "Search keyword in title") @RequestParam(required = false) String keyword
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
            log.error("Error listing public posts", e);
            res.setInternalServer();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(res);
        }
    }

    @Operation(summary = "Get post by ID", description = "Retrieves a post and increments its view counter.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Post found"),
            @ApiResponse(responseCode = "404", description = "Post not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @GetMapping("/{id}")
    public ResponseEntity<MessageRes> getById(@PathVariable Integer id) {
        MessageRes res = new MessageRes();
        try {
            Post post = postService.findById(id);
            res.setSuccess(post);
            return ResponseEntity.ok(res);
        } catch (AppException e) {
            return ResponseEntity.status(e.getHttpStatus())
                    .body(new MessageRes(e.getErrorCode(), e.getMessage(), null));
        } catch (Exception e) {
            log.error("Error getting public post by id {}", id, e);
            res.setInternalServer();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(res);
        }
    }

    @Operation(summary = "Like a post", description = "Increments the like counter by 1. No authentication required.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Like recorded — returns updated post reactions"),
            @ApiResponse(responseCode = "404", description = "Post not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/{id}/like")
    public ResponseEntity<MessageRes> like(@PathVariable Integer id) {
        MessageRes res = new MessageRes();
        try {
            Post post = postService.like(id);
            res.setSuccess(post.getReactions());
            return ResponseEntity.ok(res);
        } catch (AppException e) {
            return ResponseEntity.status(e.getHttpStatus())
                    .body(new MessageRes(e.getErrorCode(), e.getMessage(), null));
        } catch (Exception e) {
            log.error("Error liking post {}", id, e);
            res.setInternalServer();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(res);
        }
    }

    @Operation(summary = "Dislike a post", description = "Increments the dislike counter by 1. No authentication required.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Dislike recorded — returns updated post reactions"),
            @ApiResponse(responseCode = "404", description = "Post not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/{id}/dislike")
    public ResponseEntity<MessageRes> dislike(@PathVariable Integer id) {
        MessageRes res = new MessageRes();
        try {
            Post post = postService.dislike(id);
            res.setSuccess(post.getReactions());
            return ResponseEntity.ok(res);
        } catch (AppException e) {
            return ResponseEntity.status(e.getHttpStatus())
                    .body(new MessageRes(e.getErrorCode(), e.getMessage(), null));
        } catch (Exception e) {
            log.error("Error disliking post {}", id, e);
            res.setInternalServer();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(res);
        }
    }
}
