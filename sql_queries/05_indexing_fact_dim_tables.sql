SET search_path TO financial_analysis;

CREATE INDEX idx_dim_customers_province ON dim_customers(province);
CREATE INDEX idx_fact_transactions_customer ON fact_transactions(customer_id);
CREATE INDEX idx_fact_transactions_date ON fact_transactions(transaction_date);
CREATE INDEX idx_fact_transactions_cat ON fact_transactions(category);
ALTER TABLE fact_transactions ADD PRIMARY KEY (transaction_id, transaction_date);