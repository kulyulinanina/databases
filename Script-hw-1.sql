-- Создание таблицы location
CREATE TABLE location (
    postcode INT PRIMARY KEY,
    state VARCHAR(50),
    country VARCHAR(50)
);

-- Создание таблицы customer
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    dob DATE,
    job_title VARCHAR(100),
    job_industry_category VARCHAR(100),
    wealth_segment VARCHAR(50),
    deceased_indicator CHAR(1),
    owns_car CHAR(3),
    address VARCHAR(255),
    property_valuation INT,
    postcode INT NOT NULL,
    CONSTRAINT fk_postcode FOREIGN KEY (postcode) REFERENCES location(postcode)
);

-- Создание таблицы product
CREATE TABLE product (
    product_id INT PRIMARY KEY,
    brand VARCHAR(100),
    product_line VARCHAR(50),
    product_class VARCHAR(50),
    product_size VARCHAR(20),
    list_price DECIMAL(10, 2),
    standard_cost DECIMAL(10, 2)
);


-- Создание таблицы transaction
CREATE TABLE transaction (
    transaction_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    online_order BOOLEAN,
    order_status VARCHAR(50),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES product(product_id)
);
