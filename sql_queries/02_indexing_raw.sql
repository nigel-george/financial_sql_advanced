SET search_path TO financial_analysis;

CREATE INDEX idx_raw_transactions_customer ON transactions(customer_id);
CREATE INDEX idx_raw_transactions_date ON transactions(transaction_date);

SELECT 'customers' AS table_name, COUNT(*) AS record_count FROM customers
UNION ALL
SELECT 'transactions' AS table_name, COUNT(*) AS record_count FROM transactions;

