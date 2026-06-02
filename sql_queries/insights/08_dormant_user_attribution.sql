SET search_path TO financial_analysis;

WITH customer_recency AS (
    SELECT 
        customer_id,
        MAX(transaction_date) AS last_active_date,
        COUNT(transaction_id) AS historic_transaction_count,
        SUM(amount) AS historic_lifetime_spend
    FROM fact_transactions
    GROUP BY customer_id
)
SELECT 
    c.customer_id,
    c.email,
    c.province,
    r.historic_transaction_count,
    ROUND(r.historic_lifetime_spend, 2) AS lost_lifetime_value,
    r.last_active_date::DATE,
    (CURRENT_DATE - r.last_active_date::DATE) AS days_dormant
FROM customer_recency r
INNER JOIN dim_customers c ON r.customer_id = c.customer_id
WHERE (CURRENT_DATE - r.last_active_date::DATE) >= 90
  AND r.historic_lifetime_spend >= 5000.00
ORDER BY lost_lifetime_value DESC
LIMIT 25;