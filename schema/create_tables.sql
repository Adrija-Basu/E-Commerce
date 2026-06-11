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
-- =========================================
-- WAREHOUSES
-- =========================================

CREATE TABLE IF NOT EXISTS warehouses (
    warehouse_id SERIAL PRIMARY KEY,

    warehouse_name VARCHAR(100) NOT NULL,

    city VARCHAR(100),
    state VARCHAR(100),

    capacity INT CHECK(capacity > 0)
);

-- =========================================
-- INVENTORY
-- =========================================

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id SERIAL PRIMARY KEY,

    product_id INT REFERENCES products(product_id)
    ON DELETE CASCADE,

    warehouse_id INT REFERENCES warehouses(warehouse_id)
    ON DELETE CASCADE,

    quantity_available INT DEFAULT 0
    CHECK(quantity_available >= 0),

    reorder_threshold INT DEFAULT 10,

    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(product_id, warehouse_id)
);

-- =========================================
-- STOCK MOVEMENTS
-- =========================================

CREATE TABLE IF NOT EXISTS stock_movements (
    movement_id SERIAL PRIMARY KEY,

    inventory_id INT REFERENCES inventory(inventory_id)
    ON DELETE CASCADE,

    movement_type VARCHAR(20)
    CHECK(movement_type IN (
        'stock_in',
        'stock_out',
        'damaged',
        'returned'
    )),

    quantity_changed INT NOT NULL,

    movement_timestamp TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP,

    notes TEXT
); 

-- =========================================
-- PAYMENTS
-- =========================================

CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,

    order_id INT REFERENCES orders(order_id),

    payment_method VARCHAR(30),

    payment_status VARCHAR(20)
    CHECK(payment_status IN (
        'pending',
        'success',
        'failed',
        'refunded'
    )),

    amount DECIMAL(10,2)
    CHECK(amount >= 0),

    gateway_reference VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- PAYMENT TRANSACTIONS
-- =========================================

CREATE TABLE IF NOT EXISTS payment_transactions (
    transaction_id SERIAL PRIMARY KEY,

    payment_id INT REFERENCES payments(payment_id)
    ON DELETE CASCADE,

    transaction_status VARCHAR(20),

    gateway_response TEXT,

    transaction_time TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- INVOICES
-- =========================================

CREATE TABLE IF NOT EXISTS invoices (
    invoice_id SERIAL PRIMARY KEY,

    order_id INT REFERENCES orders(order_id),

    payment_id INT REFERENCES payments(payment_id),

    invoice_number VARCHAR(100) UNIQUE,

    invoice_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    total_amount DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS carts (
    cart_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer_profiles(customer_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cart_items (
    cart_item_id SERIAL PRIMARY KEY,
    cart_id INT REFERENCES carts(cart_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id),
    quantity INT CHECK(quantity > 0),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer_profiles(customer_id),
    order_status VARCHAR(20)
    CHECK(order_status IN ('pending','confirmed','shipped','delivered','cancelled')),
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id),
    quantity INT CHECK(quantity > 0),
    price_at_purchase DECIMAL(10,2)
);