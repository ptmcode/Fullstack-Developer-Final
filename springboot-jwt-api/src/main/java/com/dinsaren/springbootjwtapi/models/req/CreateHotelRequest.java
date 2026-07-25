package com.dinsaren.springbootjwtapi.models.req;


import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateHotelRequest {
    private Integer id;
    private Integer userId;
    private String imageUrl;
    private String name;
    private String description;
    private String phone;
    private String email;
    private int categoryHotelId;
}
