package com.dinsaren.springbootjwtapi.services;

import com.dinsaren.springbootjwtapi.models.FileImageDetail;
import com.dinsaren.springbootjwtapi.models.res.UploadImageRes;
import org.springframework.web.multipart.MultipartFile;

public interface UploadFileService {
    UploadImageRes uploadFile(MultipartFile files);

    FileImageDetail findImageByFileName(String fileName);
}
