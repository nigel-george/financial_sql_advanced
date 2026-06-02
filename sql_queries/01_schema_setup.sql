CREATE SCHEMA IF NOT EXISTS financial_analysis;
SET search_path TO financial_analysis;

DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;

CREATE TABLE customers (
    customer_id UUID PRIMARY KEY,
    account_created_date DATE NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number VARCHAR(25),
    province VARCHAR(2) NOT NULL,
    risk_score INT NOT NULL
);

CREATE TABLE transactions (
    transaction_id UUID,
    customer_id UUID NOT NULL,
    transaction_date TIMESTAMP NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    category VARCHAR(50) NOT NULL
) PARTITION BY RANGE (transaction_date);

CREATE TABLE transactions_2021 PARTITION OF transactions FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');
CREATE TABLE transactions_2022 PARTITION OF transactions FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE transactions_2023 PARTITION OF transactions FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE transactions_2024 PARTITION OF transactions FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE transactions_2025 PARTITION OF transactions FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE transactions_2026 PARTITION OF transactions FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');