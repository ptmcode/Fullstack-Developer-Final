package com.dinsaren.springbootjwtapi.models.req;


import lombok.Data;

@Data
public class BasePostReq {
    private Integer limit;
    private Integer page;
    private Integer userId;
    private String status;

    private Integer id;

    private Integer categoryId;

    private String name;
    private String type="ALL";
    private int categoryHotelId=0;
}
