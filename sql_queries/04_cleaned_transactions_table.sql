SET search_path TO financial_analysis;

INSERT INTO fact_transactions (transaction_id, customer_id, transaction_date, amount, category)
WITH deduplicated_ledger AS (
    SELECT 
        transaction_id,
        customer_id,
        transaction_date,
        amount,
        INITCAP(category) AS normalized_category,
        ROW_NUMBER() OVER(
            PARTITION BY customer_id, transaction_date, amount 
            ORDER BY transaction_id ASC
        ) AS occurrence_rank
    FROM transactions
)
SELECT 
    transaction_id,
    customer_id,
    transaction_date,
    amount,
    normalized_category
FROM deduplicated_ledger
WHERE occurrence_rank = 1; 