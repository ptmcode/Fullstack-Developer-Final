package com.dinsaren.springbootjwtapi.models;

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
@Table(name = "otp_logs")
@DynamicUpdate()
@Data
public class OtpLog extends BaseEntity {
    private static final long serialVersionUID = 4489397646584896516L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String token;
    private String sendTo;
    private String otp;
    private String otpMessage;
    private String status;
    private String actionType;

}