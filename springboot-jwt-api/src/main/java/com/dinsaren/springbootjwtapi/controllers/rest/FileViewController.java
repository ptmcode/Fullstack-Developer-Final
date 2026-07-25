package com.dinsaren.springbootjwtapi.controllers.rest;

import com.dinsaren.springbootjwtapi.models.FileImageDetail;
import com.dinsaren.springbootjwtapi.payload.response.MessageRes;
import com.dinsaren.springbootjwtapi.services.UploadFileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.nio.file.Files;

@Slf4j
@RestController
@RequestMapping("/api/public")
@Tag(name = "File (Public)", description = "Public file serving — no authentication required")
@SecurityRequirements
public class FileViewController {
    private final UploadFileService uploadFileService;
    private MessageRes resMessage;

    public FileViewController(UploadFileService uploadFileService) {
        this.uploadFileService = uploadFileService;
    }

    @Operation(summary = "View image by filename", description = "Streams the raw image bytes. Supports JPEG, PNG and GIF.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Image returned"),
            @ApiResponse(responseCode = "404", description = "Image not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @GetMapping(value = "/view/image",
            produces = {MediaType.IMAGE_JPEG_VALUE, MediaType.IMAGE_PNG_VALUE, MediaType.IMAGE_GIF_VALUE})
    public ResponseEntity<byte[]> getImageById(
            @Parameter(description = "Stored filename returned by the upload endpoint")
            @RequestParam("filename") String filename) {
        log.debug("Intercept view image file by filename : {}", filename);
        try {
            FileImageDetail detail = uploadFileService.findImageByFileName(filename);
            if (detail == null) {
                return null;
            }
            String path = detail.getFilePath();
            File file = new File(path);
            return ResponseEntity.ok(Files.readAllBytes(file.toPath()));
        } catch (Throwable e) {
            log.error("Errors while view image", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        } finally {
            log.info("Final Response Get Image {}", filename);
        }
    }
}