package com.dinsaren.springbootjwtapi.controllers.rest;

import com.dinsaren.springbootjwtapi.models.res.UploadImageRes;
import com.dinsaren.springbootjwtapi.payload.response.MessageRes;
import com.dinsaren.springbootjwtapi.services.UploadFileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@RestController
@RequestMapping("/app/public")
@Tag(name = "File Upload", description = "Upload image files")
public class UploadFileController {
    private final UploadFileService uploadFileService;
    private MessageRes resMessage;

    public UploadFileController(UploadFileService uploadFileService) {
        this.uploadFileService = uploadFileService;
    }

    @Operation(summary = "Upload image", description = "Upload a single image file. Returns the stored filename for use with the view-image endpoint.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Image uploaded successfully, returns filename"),
            @ApiResponse(responseCode = "500", description = "Upload failed")
    })
    @PostMapping(value = "/v1/image/upload", consumes = {"multipart/form-data"})
    public ResponseEntity<Object> uploadFile(@RequestParam("File") MultipartFile file) {
        log.debug("Intercept upload file req {}", file.toString());
        try {
            UploadImageRes res = uploadFileService.uploadFile(file);
            resMessage = new MessageRes();
            resMessage.setMessageCreateSuccess(res);
            return ResponseEntity.ok(resMessage);
        } catch (Throwable e) {
            log.error("Error while get all category {}", e.getMessage());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Final Response Get Image {}", file.getOriginalFilename());
        }
    }
}