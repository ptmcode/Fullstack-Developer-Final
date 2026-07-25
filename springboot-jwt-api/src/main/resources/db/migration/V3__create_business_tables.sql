-- ============================================================
-- School Management System — V3: business module
-- ============================================================

CREATE TABLE enrollments (
    id          SERIAL PRIMARY KEY,
    student_id  INT        NOT NULL,
    class_id    INT        NOT NULL,
    enrolled_at TIMESTAMP  NOT NULL DEFAULT NOW(),
    status      VARCHAR(3) NOT NULL DEFAULT 'ACT',
    created_at  TIMESTAMP,
    created_by  VARCHAR(100),
    updated_at  TIMESTAMP,
    updated_by  VARCHAR(100),
    CONSTRAINT fk_enrollments_student FOREIGN KEY (student_id) REFERENCES students (id),
    CONSTRAINT fk_enrollments_class   FOREIGN KEY (class_id)   REFERENCES classes (id),
    CONSTRAINT uq_enrollments_student_class UNIQUE (student_id, class_id)
);

CREATE TABLE grades (
    id            SERIAL PRIMARY KEY,
    enrollment_id INT           NOT NULL,
    subject_id    INT           NOT NULL,
    score         NUMERIC(5, 2) NOT NULL,
    term          VARCHAR(10)   NOT NULL,
    graded_by     VARCHAR(50),
    status        VARCHAR(3)    NOT NULL DEFAULT 'ACT',
    created_at    TIMESTAMP,
    created_by    VARCHAR(100),
    updated_at    TIMESTAMP,
    updated_by    VARCHAR(100),
    CONSTRAINT fk_grades_enrollment FOREIGN KEY (enrollment_id) REFERENCES enrollments (id),
    CONSTRAINT fk_grades_subject    FOREIGN KEY (subject_id)    REFERENCES subjects (id),
    CONSTRAINT uq_grades_enrollment_subject_term UNIQUE (enrollment_id, subject_id, term),
    CONSTRAINT ck_grades_score CHECK (score >= 0 AND score <= 100)
);
