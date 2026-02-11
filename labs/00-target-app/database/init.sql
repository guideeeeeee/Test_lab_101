-- Database initialization script
-- Simulates a corporate database structure

CREATE DATABASE IF NOT EXISTS corporate_db;
USE corporate_db;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2),
    stock INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample data
INSERT INTO users (username, email) VALUES
    ('admin', 'admin@corporate.local'),
    ('john.doe', 'john.doe@corporate.local'),
    ('jane.smith', 'jane.smith@corporate.local');

INSERT INTO products (name, description, price, stock) VALUES
    ('Enterprise Server License', '1-year enterprise server license', 9999.99, 100),
    ('Cloud Storage (1TB)', 'Secure cloud storage solution', 499.99, 500),
    ('Support Package', 'Premium 24/7 support', 2499.99, 50);

-- Create application user (matches docker-compose.yml)
-- This is already created by MYSQL_USER environment variable,
-- but we ensure proper permissions here
GRANT SELECT, INSERT, UPDATE, DELETE ON corporate_db.* TO 'webapp'@'%';
FLUSH PRIVILEGES;
