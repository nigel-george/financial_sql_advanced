SET search_path TO financial_analysis;

WITH transaction_velocity_ledger AS (
    SELECT 
        transaction_id,
        customer_id,
        transaction_date,
        amount,
        category,
        LAG(transaction_date) OVER (
            PARTITION BY customer_id 
            ORDER BY transaction_date ASC
        ) AS prior_transaction_timestamp,
        LAG(amount) OVER (
            PARTITION BY customer_id 
            ORDER BY transaction_date ASC
        ) AS prior_transaction_amount
    FROM fact_transactions
),
time_delta_calculations AS (
    SELECT 
        customer_id,
        transaction_id,
        prior_transaction_timestamp,
        transaction_date AS current_transaction_timestamp,
        prior_transaction_amount,
        amount AS current_transaction_amount,
        (transaction_date - prior_transaction_timestamp) AS time_elapsed_duration
    FROM transaction_velocity_ledger
    WHERE prior_transaction_timestamp IS NOT NULL
)
SELECT 
    customer_id,
    transaction_id,
    TO_CHAR(prior_transaction_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS first_swipe,
    TO_CHAR(current_transaction_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS rapid_followup_swipe,
    prior_transaction_amount,
    current_transaction_amount,
    time_elapsed_duration AS time_lapse
FROM time_delta_calculations
WHERE time_elapsed_duration <= INTERVAL '15 minutes'
  AND current_transaction_amount > 150.00
ORDER BY time_elapsed_duration ASC, current_transaction_amount DESC
LIMIT 20;