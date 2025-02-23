CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    DOB DATE,
    job_title VARCHAR(100),
    job_industry_category VARCHAR(100),
    wealth_segment VARCHAR(50),
    deceased_indicator VARCHAR(10),
    owns_car VARCHAR(10),
    address VARCHAR(255),
    postcode VARCHAR(20),
    state VARCHAR(50),
    country VARCHAR(50),
    property_valuation INT
);

CREATE TABLE transaction (
    transaction_id INT PRIMARY KEY,
    product_id INT,
    customer_id INT REFERENCES customer(customer_id) ON DELETE CASCADE,
    transaction_date DATE,
    online_order BOOLEAN,
    order_status VARCHAR(50),
    brand VARCHAR(50),
    product_line VARCHAR(50),
    product_class VARCHAR(50),
    product_size VARCHAR(50),
    list_price FLOAT,
    standard_cost FLOAT
);

SELECT DISTINCT brand 
FROM transaction 
WHERE standard_cost > 1500;

SELECT * 
FROM transaction 
WHERE order_status = 'Approved' 
AND transaction_date BETWEEN '2017-04-01' AND '2017-04-09';

SELECT * 
FROM customer 
WHERE job_industry_category IN ('IT', 'Financial Services') 
AND job_title LIKE 'Senior%';

SELECT DISTINCT t.brand FROM transaction t
JOIN customer c ON t.customer_id = c.customer_id
WHERE c.job_industry_category = 'Financial Services';

SELECT c.*
FROM customer c
JOIN transaction t ON c.customer_id = t.customer_id
WHERE t.online_order = 'True'
AND t.brand IN ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
LIMIT 10;


SELECT * 
FROM customer 
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM transaction);

SELECT c.*
FROM customer c
JOIN transaction t ON c.customer_id = t.customer_id
WHERE c.job_industry_category = 'IT'
AND t.standard_cost = (SELECT MAX(standard_cost) FROM transaction);

SELECT c.*
FROM customer c
JOIN transaction t ON c.customer_id = t.customer_id
WHERE c.job_industry_category IN ('IT', 'Health')
AND t.order_status = 'Approved'
AND t.transaction_date BETWEEN '2017-07-07' AND '2017-07-17';