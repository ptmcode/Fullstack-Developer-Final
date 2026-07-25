package com.dinsaren.springbootjwtapi.models.req;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.ArrayList;
import java.util.List;

@Data
public class PostUpdateReq {
    @NotBlank
    private String title;
    private String description;
    private String body;
    private String image;
    @NotNull
    private Integer categoryId;
    private List<String> tags = new ArrayList<>();
}