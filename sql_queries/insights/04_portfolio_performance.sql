SET search_path TO financial_analysis;

WITH provincial_allocations AS (
    SELECT 
        c.province,
        SUM(t.amount) AS provincial_asset_volume,
        COUNT(t.transaction_id) AS asset_allocation_count,
        ROUND(AVG(c.risk_score), 2) AS weighted_risk_profile
    FROM fact_transactions t
    INNER JOIN dim_customers c ON t.customer_id = c.customer_id
    GROUP BY c.province
)
SELECT 
    province AS asset_node,
    provincial_asset_volume,
    asset_allocation_count,
    ROUND((provincial_asset_volume / SUM(provincial_asset_volume) OVER ()) * 100, 2) AS allocation_weight_pct,
    weighted_risk_profile,
    CASE 
        WHEN weighted_risk_profile > 55 THEN 'High Exposure'
        WHEN weighted_risk_profile BETWEEN 45 AND 55 THEN 'Moderate Balanced'
        ELSE 'Conservative'
    END AS risk_tier
FROM provincial_allocations
ORDER BY provincial_asset_volume DESC;