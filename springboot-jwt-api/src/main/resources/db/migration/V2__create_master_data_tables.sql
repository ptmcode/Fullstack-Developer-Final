-- ============================================================
-- School Management System — V2: master data
-- ============================================================

CREATE TABLE students (
    id            SERIAL PRIMARY KEY,
    student_code  VARCHAR(20)  NOT NULL UNIQUE,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    gender        VARCHAR(10),
    date_of_birth DATE,
    email         VARCHAR(100),
    phone         VARCHAR(20),
    address       VARCHAR(255),
    status        VARCHAR(3)   NOT NULL DEFAULT 'ACT',
    created_at    TIMESTAMP,
    created_by    VARCHAR(100),
    updated_at    TIMESTAMP,
    updated_by    VARCHAR(100)
);

CREATE TABLE teachers (
    id             SERIAL PRIMARY KEY,
    teacher_code   VARCHAR(20)  NOT NULL UNIQUE,
    first_name     VARCHAR(100) NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    gender         VARCHAR(10),
    email          VARCHAR(100),
    phone          VARCHAR(20),
    specialization VARCHAR(100),
    status         VARCHAR(3)   NOT NULL DEFAULT 'ACT',
    created_at     TIMESTAMP,
    created_by     VARCHAR(100),
    updated_at     TIMESTAMP,
    updated_by     VARCHAR(100)
);

CREATE TABLE subjects (
    id           SERIAL PRIMARY KEY,
    subject_code VARCHAR(20)  NOT NULL UNIQUE,
    name         VARCHAR(100) NOT NULL,
    credit       INT,
    description  VARCHAR(255),
    status       VARCHAR(3)   NOT NULL DEFAULT 'ACT',
    created_at   TIMESTAMP,
    created_by   VARCHAR(100),
    updated_at   TIMESTAMP,
    updated_by   VARCHAR(100)
);

CREATE TABLE classes (
    id            SERIAL PRIMARY KEY,
    class_code    VARCHAR(20)  NOT NULL UNIQUE,
    name          VARCHAR(100) NOT NULL,
    academic_year VARCHAR(9),
    teacher_id    INT,
    capacity      INT,
    status        VARCHAR(3)   NOT NULL DEFAULT 'ACT',
    created_at    TIMESTAMP,
    created_by    VARCHAR(100),
    updated_at    TIMESTAMP,
    updated_by    VARCHAR(100),
    CONSTRAINT fk_classes_teacher FOREIGN KEY (teacher_id) REFERENCES teachers (id)
);
