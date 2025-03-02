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

-- 1. Распределение клиентов по сферам деятельности
SELECT job_industry_category, COUNT(*) AS client_count
FROM customer
GROUP BY job_industry_category
ORDER BY client_count DESC;

-- 2. Сумма транзакций за каждый месяц по сферам деятельности
SELECT 
    TO_CHAR(transaction_date, 'YYYY-MM') AS transaction_month,
    c.job_industry_category,
    SUM(t.list_price) AS total_transactions
FROM transaction t
JOIN customer c ON t.customer_id = c.customer_id
GROUP BY transaction_month, c.job_industry_category
ORDER BY transaction_month, c.job_industry_category;

-- 3. Количество подтвержденных онлайн-заказов клиентов из сферы IT для всех брендов
SELECT t.brand, COUNT(*) AS online_orders
FROM transaction t
JOIN customer c ON t.customer_id = c.customer_id
WHERE c.job_industry_category = 'IT'
  AND t.online_order = TRUE
  AND t.order_status = 'Approved'
GROUP BY t.brand;

-- 4.1. Сумма, макс, мин и количество транзакций (Group By)
SELECT 
    customer_id,
    SUM(list_price) AS total_transactions,
    MAX(list_price) AS max_transaction,
    MIN(list_price) AS min_transaction,
    COUNT(*) AS transaction_count
FROM transaction
GROUP BY customer_id
ORDER BY total_transactions DESC, transaction_count DESC;

-- 4.2. Сумма, макс, мин и количество транзакций (Оконные функции)
SELECT DISTINCT customer_id,
       SUM(list_price) OVER (PARTITION BY customer_id) AS total_transactions,
       MAX(list_price) OVER (PARTITION BY customer_id) AS max_transaction,
       MIN(list_price) OVER (PARTITION BY customer_id) AS min_transaction,
       COUNT(*) OVER (PARTITION BY customer_id) AS transaction_count
FROM transaction
ORDER BY SUM(list_price) OVER (PARTITION BY customer_id) DESC, COUNT(*) OVER (PARTITION BY customer_id) DESC;

-- 5.1. Клиенты с минимальной суммой транзакций
WITH CustomerSums AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(t.list_price) AS total_transactions
    FROM transaction t
    JOIN customer c ON t.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT * FROM CustomerSums WHERE total_transactions = (SELECT MIN(total_transactions) FROM CustomerSums);

-- 5.2. Клиенты с максимальной суммой транзакций
WITH CustomerSums AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(t.list_price) AS total_transactions
    FROM transaction t
    JOIN customer c ON t.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT * FROM CustomerSums WHERE total_transactions = (SELECT MAX(total_transactions) FROM CustomerSums);

-- 6. Самые первые транзакции клиентов
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY transaction_date) AS rn
    FROM transaction
) t WHERE rn = 1;

-- 7. Клиенты с максимальным интервалом между транзакциями
WITH TransactionGaps AS (
    SELECT 
        c.customer_id, 
        c.first_name, 
        c.last_name, 
        c.job_title, 
        transaction_date - LAG(transaction_date) OVER (PARTITION BY c.customer_id ORDER BY transaction_date) AS txn_interval
    FROM transaction t
    JOIN customer c ON t.customer_id = c.customer_id
)
SELECT customer_id, first_name, last_name, job_title, txn_interval
FROM TransactionGaps
WHERE txn_interval = (SELECT MAX(txn_interval) FROM TransactionGaps);