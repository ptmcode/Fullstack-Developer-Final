package com.dinsaren.springbootjwtapi.models;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Data;

@Embeddable
@Data
public class Reactions {
    @Column(name = "likes", nullable = false, columnDefinition = "INT DEFAULT 0")
    private int likes = 0;

    @Column(name = "dislikes", nullable = false, columnDefinition = "INT DEFAULT 0")
    private int dislikes = 0;
}