SET search_path TO financial_analysis;

WITH baseline_category_budgets AS (
    SELECT * FROM (VALUES 
        ('Retail', 7000000.00),
        ('Food & Dining', 5000000.00),
        ('Utilities', 2000000.00),
        ('Travel & Entertainment', 3000000.00),
        ('Investment Tranche', 1500000.00)
    ) AS budget_matrix(target_category, budgeted_amount)
),
actual_spending AS (
    SELECT 
        category AS actual_category,
        SUM(amount) AS actual_amount_spent
    FROM fact_transactions
    GROUP BY category
)
SELECT 
    b.target_category AS category_line_item,
    b.budgeted_amount,
    ROUND(a.actual_amount_spent, 2) AS actual_amount,
    ROUND(a.actual_amount_spent - b.budgeted_amount, 2) AS variance_dollars,
    ROUND(((a.actual_amount_spent - b.budgeted_amount) / b.budgeted_amount) * 100, 2) AS variance_pct,
    CASE 
        WHEN a.actual_amount_spent > b.budgeted_amount THEN 'OVER BUDGET'
        ELSE 'UNDER BUDGET'
    END AS operational_status
FROM baseline_category_budgets b
LEFT JOIN actual_spending a ON b.target_category = a.actual_category
ORDER BY variance_dollars DESC;