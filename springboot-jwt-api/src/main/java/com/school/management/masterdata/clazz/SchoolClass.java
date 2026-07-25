package com.school.management.masterdata.clazz;

import com.school.management.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/** Named SchoolClass because "class" is a reserved word in Java; the table is "classes". */
@Getter
@Setter
@Entity
@Table(name = "classes")
public class SchoolClass extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "class_code", nullable = false, unique = true, length = 20)
    private String classCode;

    @Column(nullable = false)
    private String name;

    @Column(name = "academic_year", length = 9)
    private String academicYear;

    @Column(name = "teacher_id")
    private Integer teacherId;

    private Integer capacity;

    @Column(nullable = false, length = 3)
    private String status;
}
