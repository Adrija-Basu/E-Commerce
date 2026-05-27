-- =========================================
-- USERS TABLE
-- =========================================

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) CHECK(role IN ('customer', 'seller', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- CUSTOMER PROFILE
-- =========================================

CREATE TABLE customer_profiles (
    customer_id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    loyalty_points INT DEFAULT 0,
    preferred_address TEXT,
    date_of_birth DATE
);

-- =========================================
-- SELLER PROFILE
-- =========================================

CREATE TABLE seller_profiles (
    seller_id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    business_name VARCHAR(150) NOT NULL,
    gst_number VARCHAR(50) UNIQUE,
    commission_rate DECIMAL(5,2) DEFAULT 10.00,
    verification_status BOOLEAN DEFAULT FALSE
);

-- =========================================
-- ADDRESSES
-- =========================================

CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    address_line TEXT NOT NULL,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    address_type VARCHAR(20) CHECK(address_type IN ('billing', 'shipping'))
);

-- =========================================
-- BRANDS
-- =========================================

CREATE TABLE brands (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) UNIQUE NOT NULL,
    verified BOOLEAN DEFAULT FALSE
);

-- =========================================
-- CATEGORIES
-- =========================================

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT REFERENCES categories(category_id)
);

-- =========================================
-- PRODUCTS
-- =========================================

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    seller_id INT REFERENCES seller_profiles(seller_id),
    brand_id INT REFERENCES brands(brand_id),

    product_name VARCHAR(200) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(200) UNIQUE,

    description TEXT,

    base_price DECIMAL(10,2) NOT NULL CHECK(base_price > 0),

    status VARCHAR(20)
    CHECK(status IN ('active', 'inactive', 'out_of_stock')),

    average_rating DECIMAL(3,2) DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- PRODUCT CATEGORIES
-- =========================================

CREATE TABLE product_categories (
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    category_id INT REFERENCES categories(category_id) ON DELETE CASCADE,

    PRIMARY KEY(product_id, category_id)
);

-- =========================================
-- PRODUCT IMAGES
-- =========================================

CREATE TABLE product_images (
    image_id SERIAL PRIMARY KEY,

    product_id INT REFERENCES products(product_id)
    ON DELETE CASCADE,

    image_url TEXT NOT NULL,

    sort_order INT DEFAULT 1
);