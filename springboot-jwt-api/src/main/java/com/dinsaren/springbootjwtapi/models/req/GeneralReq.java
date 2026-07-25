package com.dinsaren.springbootjwtapi.models.req;

import lombok.Data;

@Data
public class GeneralReq {
    private String originalText;
    private String phoneNumber;
}
