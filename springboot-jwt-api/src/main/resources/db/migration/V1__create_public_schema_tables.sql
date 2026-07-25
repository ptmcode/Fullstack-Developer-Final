-- ============================================================
-- Hibernate sequence
-- ============================================================
CREATE SCHEMA IF NOT EXISTS public;
CREATE SEQUENCE IF NOT EXISTS hibernate_sequence START 1 INCREMENT 1;

-- ============================================================
-- roles
-- ============================================================
CREATE TABLE IF NOT EXISTS roles (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(20),
    created_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255)
);

INSERT INTO roles (name) SELECT 'ROLE_CUSTOMER' WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_CUSTOMER');
INSERT INTO roles (name) SELECT 'ROLE_USER'     WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_USER');
INSERT INTO roles (name) SELECT 'ROLE_MODERATOR'WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_MODERATOR');
INSERT INTO roles (name) SELECT 'ROLE_ADMIN'    WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_ADMIN');
INSERT INTO roles (name) SELECT 'ROLE_SHOP'     WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_SHOP');
INSERT INTO roles (name) SELECT 'ROLE_CASHIER'  WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_CASHIER');
INSERT INTO roles (name) SELECT 'ROLE_MERCHANT' WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_MERCHANT');
INSERT INTO roles (name) SELECT 'ROLE_CREATOR'  WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_CREATOR');
INSERT INTO roles (name) SELECT 'ROLE_REVIEWER' WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_REVIEWER');

-- ============================================================
-- users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id              SERIAL PRIMARY KEY,
    username        VARCHAR(255),
    first_name      VARCHAR(255),
    last_name       VARCHAR(255),
    email           VARCHAR(255),
    verify_email    VARCHAR(255),
    phone_number    VARCHAR(255),
    password        VARCHAR(255),
    status          VARCHAR(255),
    profile         VARCHAR(255),
    change_password VARCHAR(255),
    created_at      TIMESTAMP,
    created_by      VARCHAR(255),
    updated_at      TIMESTAMP,
    updated_by      VARCHAR(255)
);

-- ============================================================
-- user_roles
-- ============================================================
CREATE TABLE IF NOT EXISTS user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles (id)
);

-- ============================================================
-- refresh_tokens
-- ============================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id          BIGSERIAL PRIMARY KEY,
    user_id     INT,
    token       VARCHAR(255) NOT NULL UNIQUE,
    expiry_date TIMESTAMP    NOT NULL,
    CONSTRAINT fk_refresh_token_user FOREIGN KEY (user_id) REFERENCES users (id)
);

-- ============================================================
-- post_categories
-- ============================================================
CREATE TABLE IF NOT EXISTS post_categories (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(255),
    image_url  VARCHAR(255),
    status     VARCHAR(255),
    created_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255)
);

-- ============================================================
-- posts
-- ============================================================
CREATE TABLE IF NOT EXISTS posts (
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(255),
    description VARCHAR(255),
    body        TEXT,
    total_view  INT     DEFAULT 0,
    likes       INT     NOT NULL DEFAULT 0,
    dislikes    INT     NOT NULL DEFAULT 0,
    status      VARCHAR(255),
    image       VARCHAR(255),
    category_id INT,
    user_id     INT,
    created_at  TIMESTAMP,
    created_by  VARCHAR(255),
    updated_at  TIMESTAMP,
    updated_by  VARCHAR(255),
    CONSTRAINT fk_post_category FOREIGN KEY (category_id) REFERENCES post_categories (id),
    CONSTRAINT fk_post_user     FOREIGN KEY (user_id)     REFERENCES users (id)
);

-- ============================================================
-- post_tags
-- ============================================================
CREATE TABLE IF NOT EXISTS post_tags (
    post_id INT          NOT NULL,
    tag     VARCHAR(100) NOT NULL,
    CONSTRAINT fk_post_tags_post FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE
);

-- ============================================================
-- otp_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS otp_logs (
    id          SERIAL PRIMARY KEY,
    token       VARCHAR(255),
    send_to     VARCHAR(255),
    otp         VARCHAR(255),
    otp_message VARCHAR(255),
    status      VARCHAR(255),
    action_type VARCHAR(255),
    created_at  TIMESTAMP,
    created_by  VARCHAR(255),
    updated_at  TIMESTAMP,
    updated_by  VARCHAR(255)
);

-- ============================================================
-- image_details
-- ============================================================
CREATE TABLE IF NOT EXISTS image_details (
    id                 SERIAL PRIMARY KEY,
    file_path          VARCHAR(255),
    file_type          VARCHAR(255),
    file_name          VARCHAR(255),
    original_file_name VARCHAR(255),
    file_size          BIGINT,
    status             VARCHAR(255),
    created_at         TIMESTAMP,
    created_by         VARCHAR(255),
    updated_at         TIMESTAMP,
    updated_by         VARCHAR(255)
);

-- ============================================================
-- product_categories
-- ============================================================
CREATE TABLE IF NOT EXISTS product_categories (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(255),
    created_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255)
);

-- ============================================================
-- products
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    id             SERIAL PRIMARY KEY,
    name           VARCHAR(255),
    product_code   VARCHAR(255),
    category_id    INT,
    price          DOUBLE PRECISION,
    cost           DOUBLE PRECISION,
    stock_quantity DOUBLE PRECISION,
    description    VARCHAR(255),
    status         VARCHAR(255),
    created_at     TIMESTAMP,
    created_by     VARCHAR(255),
    updated_at     TIMESTAMP,
    updated_by     VARCHAR(255),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES product_categories (id)
);

-- ============================================================
-- Hotel schema
-- ============================================================
CREATE SCHEMA IF NOT EXISTS hotel;

CREATE TABLE IF NOT EXISTS hotel.category_hotel (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(255),
    status     VARCHAR(3),
    created_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS hotel.hotel (
    id                SERIAL PRIMARY KEY,
    user_id           INT,
    image_url         VARCHAR(255),
    name              VARCHAR(255),
    decription        VARCHAR(255),
    phone             VARCHAR(22),
    email             VARCHAR(22),
    status            VARCHAR(3),
    category_hotel_id INT,
    created_at        TIMESTAMP,
    created_by        VARCHAR(255),
    updated_at        TIMESTAMP,
    updated_by        VARCHAR(255),
    CONSTRAINT fk_hotel_category FOREIGN KEY (category_hotel_id) REFERENCES hotel.category_hotel (id)
);

CREATE TABLE IF NOT EXISTS hotel.floor (
    id         SERIAL PRIMARY KEY,
    hotel_id   INT,
    number_no  VARCHAR(255),
    decription VARCHAR(255),
    status     VARCHAR(3),
    created_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    CONSTRAINT fk_floor_hotel FOREIGN KEY (hotel_id) REFERENCES hotel.hotel (id)
);

CREATE TABLE IF NOT EXISTS hotel.room (
    id         SERIAL PRIMARY KEY,
    floor_id   INT,
    number_no  VARCHAR(255),
    decription VARCHAR(255),
    price      NUMERIC(12, 4),
    status     VARCHAR(3),
    created_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    CONSTRAINT fk_room_floor FOREIGN KEY (floor_id) REFERENCES hotel.floor (id)
);

CREATE TABLE IF NOT EXISTS hotel.customer (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(255),
    phone      VARCHAR(255),
    email      VARCHAR(255),
    status     VARCHAR(3),
    created_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS hotel.book_room (
    id            SERIAL PRIMARY KEY,
    hotel_id      INT,
    customer_id   INT,
    date          TIMESTAMP,
    checkin_date  TIMESTAMP,
    checkout_date TIMESTAMP,
    total_price   NUMERIC(12, 4),
    status        VARCHAR(3),
    created_at    TIMESTAMP,
    created_by    VARCHAR(255),
    updated_at    TIMESTAMP,
    updated_by    VARCHAR(255),
    CONSTRAINT fk_book_room_hotel    FOREIGN KEY (hotel_id)    REFERENCES hotel.hotel (id),
    CONSTRAINT fk_book_room_customer FOREIGN KEY (customer_id) REFERENCES hotel.customer (id)
);

CREATE TABLE IF NOT EXISTS hotel.book_room_item (
    id           SERIAL PRIMARY KEY,
    book_room_id INT,
    room_id      INT,
    price        NUMERIC(12, 4),
    qty          NUMERIC(12, 4),
    status       VARCHAR(3),
    created_at   TIMESTAMP,
    created_by   VARCHAR(255),
    updated_at   TIMESTAMP,
    updated_by   VARCHAR(255),
    CONSTRAINT fk_book_room_item_book_room FOREIGN KEY (book_room_id) REFERENCES hotel.book_room (id),
    CONSTRAINT fk_book_room_item_room      FOREIGN KEY (room_id)      REFERENCES hotel.room (id)
);
