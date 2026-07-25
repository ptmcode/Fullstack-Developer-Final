package com.dinsaren.springbootjwtapi.models.res;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

@EqualsAndHashCode(callSuper = false)
public class UploadImageRes {

    @Getter
    @Setter
    @JsonProperty("data")
    private String fileName;
}
