SET search_path TO financial_analysis;


DROP TABLE IF EXISTS dim_customers CASCADE;
DROP TABLE IF EXISTS fact_transactions CASCADE;


CREATE TABLE dim_customers (
    customer_key SERIAL PRIMARY KEY, 
    customer_id INT UNIQUE,
    account_created_date DATE NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number VARCHAR(25) NOT NULL, 
    province VARCHAR(2) NOT NULL,
    risk_score INT NOT NULL
);


CREATE TABLE fact_transactions (
    transaction_id INT,
    customer_id INT,
    transaction_date TIMESTAMP NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    category VARCHAR(50) NOT NULL
) PARTITION BY RANGE (transaction_date);


CREATE TABLE fact_transactions_2021 PARTITION OF fact_transactions FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');
CREATE TABLE fact_transactions_2022 PARTITION OF fact_transactions FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE fact_transactions_2023 PARTITION OF fact_transactions FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE fact_transactions_2024 PARTITION OF fact_transactions FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE fact_transactions_2025 PARTITION OF fact_transactions FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE fact_transactions_2026 PARTITION OF fact_transactions FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');