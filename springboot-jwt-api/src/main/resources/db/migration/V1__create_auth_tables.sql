-- ============================================================
-- School Management System — V1: authentication & authorization
-- ============================================================

CREATE TABLE users (
    id           SERIAL PRIMARY KEY,
    username     VARCHAR(50)  NOT NULL UNIQUE,
    email        VARCHAR(100) NOT NULL UNIQUE,
    password     VARCHAR(100) NOT NULL,
    first_name   VARCHAR(100),
    last_name    VARCHAR(100),
    phone_number VARCHAR(20),
    status       VARCHAR(3)   NOT NULL DEFAULT 'ACT',
    created_at   TIMESTAMP,
    created_by   VARCHAR(100),
    updated_at   TIMESTAMP,
    updated_by   VARCHAR(100)
);

CREATE TABLE roles (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at  TIMESTAMP,
    created_by  VARCHAR(100),
    updated_at  TIMESTAMP,
    updated_by  VARCHAR(100)
);

CREATE TABLE permissions (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles (id)
);

CREATE TABLE role_permissions (
    role_id       INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_role_permissions_role       FOREIGN KEY (role_id)       REFERENCES roles (id),
    CONSTRAINT fk_role_permissions_permission FOREIGN KEY (permission_id) REFERENCES permissions (id)
);

CREATE TABLE refresh_tokens (
    id          BIGSERIAL PRIMARY KEY,
    user_id     INT          NOT NULL,
    token       VARCHAR(100) NOT NULL UNIQUE,
    expiry_date TIMESTAMP    NOT NULL,
    CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE password_reset_tokens (
    id          BIGSERIAL PRIMARY KEY,
    user_id     INT          NOT NULL,
    token       VARCHAR(100) NOT NULL UNIQUE,
    expiry_date TIMESTAMP    NOT NULL,
    used        VARCHAR(1)   NOT NULL DEFAULT 'N',
    CONSTRAINT fk_password_reset_tokens_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE audit_logs (
    id          BIGSERIAL PRIMARY KEY,
    user_id     INT,
    username    VARCHAR(50),
    action      VARCHAR(30) NOT NULL,
    entity_type VARCHAR(50),
    entity_id   VARCHAR(50),
    detail      VARCHAR(500),
    ip_address  VARCHAR(50),
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX idx_audit_logs_username   ON audit_logs (username);
CREATE INDEX idx_audit_logs_action     ON audit_logs (action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs (created_at);
