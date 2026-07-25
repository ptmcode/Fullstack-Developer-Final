package com.dinsaren.springbootjwtapi.services;

import com.dinsaren.springbootjwtapi.constants.Constants;
import com.dinsaren.springbootjwtapi.models.FileImageDetail;
import com.dinsaren.springbootjwtapi.models.res.UploadImageRes;
import com.dinsaren.springbootjwtapi.repository.FileImageDetailRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.Calendar;

@Slf4j
@Service
public class UploadFileServiceImpl implements UploadFileService {

    @Value("${spring.upload.server.path}")
    String serverPath;
    @Autowired
    private FileImageDetailRepository fileImageDetailRepository;

    @Override
    public UploadImageRes uploadFile(MultipartFile files) {

        if (files.isEmpty()) {
            log.error("Failed to store empty file");
        }

        String writePath = serverPath;

        File file = new File(writePath);
        if (!file.exists()) {
            file.mkdirs();
        }

        UploadImageRes imageRes = new UploadImageRes();
        String name = StringUtils.cleanPath(files.getOriginalFilename());
        String extension = getFileExtension(name);
        String extensions = "jpeg,png,jpg";
        if (!extensions.contains(extension.toLowerCase())) {
            log.error("Invalid File Extension {}", extension);
        }
        imageRes.setFileName(Calendar.getInstance().getTimeInMillis() + "." + extension);
        file = new File(writePath + imageRes.getFileName());
        FileImageDetail fileImageDetail = new FileImageDetail();
        try {
            files.transferTo(file);
            if (!files.isEmpty()) {
                fileImageDetail.setFilePath(file.getPath());
                fileImageDetail.setFileType(files.getContentType());
                fileImageDetail.setFileName(imageRes.getFileName());
                fileImageDetail.setOriginalFileName(getFileNoExtension(name));
                fileImageDetail.setFileSize(files.getSize());
                fileImageDetail.setStatus(Constants.STATUS_ACTIVE);
                fileImageDetailRepository.save(fileImageDetail);
            }
        } catch (IOException e) {
            log.error("upload file fail", e);
        }finally {
            log.info("Final exception {}", fileImageDetail);
        }
        imageRes.setFileName(fileImageDetail.getFileName());
        return imageRes;
    }

    String getFileExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex < 0) {
            return null;
        }
        return fileName.substring(dotIndex + 1);
    }

    String getFileNoExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex < 0) {
            return null;
        }
        return fileName.substring(0, dotIndex);
    }

    @Override
    public FileImageDetail findImageByFileName(String filename) {
        return fileImageDetailRepository.findByFileNameAndStatus(filename, Constants.STATUS_ACTIVE);
    }

}
