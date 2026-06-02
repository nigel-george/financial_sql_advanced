SET search_path TO financial_analysis;

WITH customer_spending_profiles AS (
    SELECT 
        t.customer_id,
        c.province,
        c.account_created_date,
        COUNT(t.transaction_id) AS lifetime_transaction_count,
        SUM(t.amount) AS lifetime_value_ltv,
        ROUND(AVG(t.amount), 2) AS average_ticket_size,
        MAX(t.transaction_date) AS most_recent_swipe
    FROM fact_transactions t
    INNER JOIN dim_customers c ON t.customer_id = c.customer_id
    GROUP BY t.customer_id, c.province, c.account_created_date
),
ranked_spenders AS (
    SELECT 
        customer_id,
        province,
        lifetime_transaction_count,
        lifetime_value_ltv,
        average_ticket_size,
        (CURRENT_DATE - most_recent_swipe::DATE) AS days_since_last_active,
        DENSE_RANK() OVER (ORDER BY lifetime_value_ltv DESC) AS whale_rank
    FROM customer_spending_profiles
)
SELECT 
    whale_rank,
    customer_id,
    province,
    lifetime_transaction_count,
    lifetime_value_ltv,
    average_ticket_size,
    days_since_last_active,
    CASE 
        WHEN lifetime_transaction_count > 100 AND days_since_last_active <= 30 THEN 'Power User'
        WHEN days_since_last_active > 180 THEN 'At Risk / Churned'
        ELSE 'Active'
    END AS lifecycle_segment
FROM ranked_spenders
WHERE whale_rank <= 20
ORDER BY whale_rank ASC;