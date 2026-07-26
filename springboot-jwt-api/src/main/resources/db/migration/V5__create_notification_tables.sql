-- ============================================================
-- School Management System — V5: push notifications (Firebase Cloud Messaging)
-- ============================================================

-- Devices registered for push. One row per (user, FCM token).
CREATE TABLE device_tokens (
    id          BIGSERIAL PRIMARY KEY,
    user_id     INT          NOT NULL,
    token       VARCHAR(255) NOT NULL UNIQUE,
    device_type VARCHAR(10),
    device_name VARCHAR(100),
    status      VARCHAR(3)   NOT NULL DEFAULT 'ACT',
    created_at  TIMESTAMP,
    created_by  VARCHAR(100),
    updated_at  TIMESTAMP,
    updated_by  VARCHAR(100),
    CONSTRAINT fk_device_tokens_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX idx_device_tokens_user ON device_tokens (user_id);

-- Notification history / in-app inbox. One row per recipient.
CREATE TABLE notifications (
    id          BIGSERIAL PRIMARY KEY,
    user_id     INT          NOT NULL,
    title       VARCHAR(150) NOT NULL,
    body        VARCHAR(500) NOT NULL,
    type        VARCHAR(30)  NOT NULL,
    entity_type VARCHAR(50),
    entity_id   VARCHAR(50),
    is_read     VARCHAR(1)   NOT NULL DEFAULT 'N',
    sent_status VARCHAR(10)  NOT NULL DEFAULT 'PENDING',
    created_at  TIMESTAMP,
    created_by  VARCHAR(100),
    updated_at  TIMESTAMP,
    updated_by  VARCHAR(100),
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX idx_notifications_user_read ON notifications (user_id, is_read);

-- ------------------------------------------------------------
-- Link a student record to a login account so the student can be
-- notified about their own enrollments and grades.
-- ------------------------------------------------------------
ALTER TABLE students ADD COLUMN user_id INT;
ALTER TABLE students ADD CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE students ADD CONSTRAINT uq_students_user UNIQUE (user_id);

-- Demo link: the seeded 'student1' account is student S001.
UPDATE students SET user_id = (SELECT id FROM users WHERE username = 'student1')
WHERE student_code = 'S001';

-- ------------------------------------------------------------
-- Permissions
-- ------------------------------------------------------------
INSERT INTO permissions (code, description) VALUES
    ('notification.read', 'Read own notifications'),
    ('notification.send', 'Send notifications to users');

-- ADMIN gets both; TEACHER may send; every role may read its own inbox.
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE p.code IN ('notification.read', 'notification.send')
  AND r.name = 'ROLE_ADMIN';

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE p.code IN ('notification.read', 'notification.send')
  AND r.name = 'ROLE_TEACHER';

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE p.code = 'notification.read'
  AND r.name = 'ROLE_STUDENT';
