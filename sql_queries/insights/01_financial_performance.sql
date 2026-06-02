SET search_path TO financial_analysis;

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', transaction_date) AS reporting_month,
        SUM(amount) AS gross_revenue,
        COUNT(transaction_id) AS volume_count
    FROM fact_transactions
    GROUP BY DATE_TRUNC('month', transaction_date)
),
financial_trends AS (
    SELECT 
        reporting_month,
        gross_revenue,
        volume_count,
        LAG(gross_revenue) OVER (ORDER BY reporting_month ASC) AS previous_month_revenue,
        AVG(gross_revenue) OVER (
            ORDER BY reporting_month ASC 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3_month_avg
    FROM monthly_revenue
)
SELECT 
    TO_CHAR(reporting_month, 'YYYY-MM') AS fiscal_period,
    gross_revenue,
    volume_count,
    ROUND(gross_revenue - previous_month_revenue, 2) AS absolute_growth,
    ROUND(((gross_revenue - previous_month_revenue) / previous_month_revenue) * 100, 2) AS mom_growth_pct,
    ROUND(rolling_3_month_avg, 2) AS smoothed_trend_revenue
FROM financial_trends
ORDER BY reporting_month DESC;