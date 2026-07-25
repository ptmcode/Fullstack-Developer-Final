package com.school.management.enrollment;

import com.school.management.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@Entity
@Table(name = "grades")
public class Grade extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "enrollment_id", nullable = false)
    private Integer enrollmentId;

    @Column(name = "subject_id", nullable = false)
    private Integer subjectId;

    @Column(nullable = false, precision = 5, scale = 2)
    private BigDecimal score;

    @Column(nullable = false, length = 10)
    private String term;

    @Column(name = "graded_by", length = 50)
    private String gradedBy;

    @Column(nullable = false, length = 3)
    private String status;
}
