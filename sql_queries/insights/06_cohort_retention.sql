SET search_path TO financial_analysis;

WITH customer_cohorts AS (
    SELECT 
        customer_id,
        EXTRACT(YEAR FROM account_created_date) AS cohort_year
    FROM dim_customers
),
activity_years AS (
    SELECT DISTINCT
        customer_id,
        EXTRACT(YEAR FROM transaction_date) AS active_year
    FROM fact_transactions
),
cohort_matrix AS (
    SELECT 
        c.cohort_year,
        a.active_year,
        COUNT(DISTINCT c.customer_id) AS active_users
    FROM customer_cohorts c
    INNER JOIN activity_years a ON c.customer_id = a.customer_id
    WHERE a.active_year >= c.cohort_year
    GROUP BY c.cohort_year, a.active_year
)
SELECT 
    cohort_year,
    MAX(CASE WHEN active_year = cohort_year THEN active_users END) AS initial_size,
    
    LEAST(ROUND(MAX(CASE WHEN active_year = cohort_year + 1 THEN active_users END)::NUMERIC / MAX(CASE WHEN active_year = cohort_year THEN active_users END) * 100, 2), 100.00) AS year_1_retention_pct,
    LEAST(ROUND(MAX(CASE WHEN active_year = cohort_year + 2 THEN active_users END)::NUMERIC / MAX(CASE WHEN active_year = cohort_year THEN active_users END) * 100, 2), 100.00) AS year_2_retention_pct,
    LEAST(ROUND(MAX(CASE WHEN active_year = cohort_year + 3 THEN active_users END)::NUMERIC / MAX(CASE WHEN active_year = cohort_year THEN active_users END) * 100, 2), 100.00) AS year_3_retention_pct
FROM cohort_matrix
GROUP BY cohort_year
ORDER BY cohort_year ASC;