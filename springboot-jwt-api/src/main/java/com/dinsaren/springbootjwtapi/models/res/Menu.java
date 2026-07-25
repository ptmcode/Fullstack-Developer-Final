package com.dinsaren.springbootjwtapi.models.res;

import lombok.Data;

@Data
public class Menu {
    private String name;
    private String nameKh;
    private String key;
    private String value;
    private String formatValue;
    private int index;
}
