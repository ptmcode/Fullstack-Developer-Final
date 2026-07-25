package com.dinsaren.springbootjwtapi.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.DynamicUpdate;

@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "post_categories")
@DynamicUpdate
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class PostCategory extends BaseEntity {
    private static final long serialVersionUID = 4489397646584896516L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String name;
    private String imageUrl;
    private String status;
}