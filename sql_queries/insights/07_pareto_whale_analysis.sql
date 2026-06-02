SET search_path TO financial_analysis;

WITH user_spend_totals AS (
    SELECT 
        customer_id,
        SUM(amount) AS total_customer_spend
    FROM fact_transactions
    GROUP BY customer_id
),
cumulative_spend_ranked AS (
    SELECT 
        customer_id,
        total_customer_spend,
        SUM(total_customer_spend) OVER (ORDER BY total_customer_spend DESC) AS running_total_spend,
        ROW_NUMBER() OVER (ORDER BY total_customer_spend DESC) AS user_rank_count,
        SUM(total_customer_spend) OVER () AS global_total_spend,
        COUNT(*) OVER () AS global_total_users
    FROM user_spend_totals
)
SELECT 
    user_rank_count AS top_n_users,
    ROUND((user_rank_count::NUMERIC / global_total_users) * 100, 2) AS population_percentile_pct,
    ROUND(total_customer_spend, 2) AS user_cutoff_spend,
    ROUND((running_total_spend / global_total_spend) * 100, 2) AS cumulative_revenue_contribution_pct
FROM cumulative_spend_ranked
WHERE user_rank_count IN (100, 500, 1000, 3000, 6000, 15000)
ORDER BY user_rank_count ASC;