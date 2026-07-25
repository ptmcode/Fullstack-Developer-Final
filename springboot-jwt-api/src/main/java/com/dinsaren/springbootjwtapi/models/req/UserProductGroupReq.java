package com.dinsaren.springbootjwtapi.models.req;

import com.dinsaren.springbootjwtapi.models.BaseEntity;
import lombok.Data;

import java.util.List;

@Data
public class UserProductGroupReq extends BaseEntity {
    private Integer id;
    private String name;
    private String nameKh;
    private String note;
    private Double price;
    private Double cost;
    private String status;
    private String userAccountId;
    private String shopId;
    private String saleDefault;
    private List<UserProductGroupDetailReq> groupDetailReqList;
}