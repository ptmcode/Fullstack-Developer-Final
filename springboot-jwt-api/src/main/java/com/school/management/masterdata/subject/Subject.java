package com.school.management.masterdata.subject;

import com.school.management.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "subjects")
public class Subject extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "subject_code", nullable = false, unique = true, length = 20)
    private String subjectCode;

    @Column(nullable = false)
    private String name;

    private Integer credit;

    private String description;

    @Column(nullable = false, length = 3)
    private String status;
}
