package com.dinsaren.springbootjwtapi.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.DynamicUpdate;

@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "image_details")
@DynamicUpdate()
public class FileImageDetail extends BaseEntity {

    private static final long serialVersionUID = 4489397646584896516L;
    @Id
    @Column(name = "ID")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @Column(name = "FILE_PATH")
    private String filePath;
    @Column(name = "FILE_TYPE")
    private String fileType;
    @Column(name = "FILE_NAME")
    private String fileName;
    @Column(name = "ORIGINAL_FILE_NAME")
    private String originalFileName;
    @Column(name = "FILE_SIZE")
    private Long fileSize;
    @Column(name = "STATUS")
    private String status;
}
