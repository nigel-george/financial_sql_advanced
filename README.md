# Canadian Financial Analytics Platform

**Python · PostgreSQL · SQL · Star Schema · 2.3M+ Rows**

An end-to-end data project simulating a production-grade Canadian consumer financial platform — from raw data generation through warehouse design, ETL cleaning, and 8 business analytics modules covering fraud detection, customer retention, FP&A, and revenue intelligence.

> Built to demonstrate real analytical thinking, not just SQL syntax. Every query answers a business question a finance or fintech team would actually ask.

---

## What this project does

A Python pipeline generates 2.3 million realistic consumer transactions across 30,000 Canadian customers (Ontario, Quebec, BC, and 7 other provinces). The raw data includes intentional quality issues — duplicate payloads, formatting inconsistencies, null timestamps — mirroring what analysts encounter in production systems.

The data flows through:

1. **Raw ingestion layer** — PostgreSQL tables with range partitioning by calendar year and B-Tree indexing for query performance
2. **ETL cleaning pipeline** — structural fixes, deduplication, type normalization
3. **Star schema data mart** — fact and dimension tables optimized for analytical queries
4. **8 analytics modules** — each targeting a distinct business domain

---

## Key findings

| Module | Business Question | Answer |
| :--- | :--- | :--- |
| Financial Performance | Where is revenue trending month-over-month? | Steady growth through 2024–2025; rolling 3-month average smooths seasonal noise |
| Customer Profiling | Who are the highest-value customers and what do they look like? | Top LTV user: $8,924 across 103 transactions, active within 4 days |
| Budget Variance | Are we hitting FP&A targets by category? | Food & Dining over-performed budget by 1,017% — signals demand mis-forecast |
| Portfolio Exposure | Where is capital geographically concentrated? | Ontario holds 39.3% of asset volume ($62.8M); Quebec 22.6% — healthy but monitored |
| Fraud Detection | Are there velocity attacks or duplicate payment payloads? | Flagged network retry duplicates: same client, same amount, `time_lapse = 00:00:00` |
| Cohort Retention | Do users stay active after registration? | ~100% Year 1 retention across all cohorts; NULL correctly appears for cohorts with no elapsed horizon |
| Pareto Analysis | Is revenue dangerously concentrated in a few users? | Top 10% of users = 12.86% of revenue — healthy distribution, no systemic bottleneck |
| Dormant Recovery | Which high-value accounts have gone silent? | Identified accounts with $7,000+ LTV dark for 90+ days — ready for reactivation campaigns |

---

## Technical design

**Data generation**
- Python 3 with `pandas`, `numpy`, `Faker` — 2.3M+ rows with built-in seasonality patterns and intentional data quality bugs for realistic ETL work

**Warehouse architecture**
- PostgreSQL with range partitioning by calendar year
- Cryptographic UUID v4 primary keys (mirroring distributed system conventions)
- B-Tree indexes on high-cardinality join and filter columns
- Star schema: `fact_transactions` joined to `dim_customer`, `dim_date`, `dim_category`

**SQL techniques used**
- Window functions: `LAG()`, `DENSE_RANK()`, `ROW_NUMBER()`, `SUM() OVER (PARTITION BY)`
- Rolling averages: `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`
- CTEs and dynamic value matrices
- Date arithmetic with `DATE_TRUNC`, `INTERVAL`, `CURRENT_DATE`
- Multi-table joins with aggregation and conditional `CASE WHEN` segmentation

---

## Analytics modules

### 01 — Financial performance
Tracks gross revenue velocity with month-over-month absolute and percentage growth. A rolling 3-month moving average smooths volatility. Surfaces a mid-2026 partial-month truncation anomaly ($224K vs. May's $4.1M) — correctly identified, not a data error.

`fiscal_period` · `gross_revenue` · `volume_count` · `absolute_growth` · `mom_growth_pct` · `smoothed_trend_revenue`

![Financial Performance Analysis](<Screenshots/Screenshot 2026-06-02 143012.png>)

---

### 02 — Customer transaction profiling
Isolates the top 20 whale accounts by lifetime value out of 30,000 users. Maps LTV, average ticket size, recency, and lifecycle segment (active power user vs. at-risk high-value) using `DENSE_RANK()` and multi-table joins.

`whale_rank` · `customer_id` · `province` · `lifetime_transaction_count` · `lifetime_value_ltv` · `average_ticket_size` · `days_since_last_active` · `lifecycle_segment`

![Customer Transaction Profiling](<Screenshots/Screenshot 2026-06-02 143052.png>)

---

### 03 — Budget variance analysis
Simulates an FP&A target tracker using a dynamic CTE matrix with hardcoded budget baselines joined against actuals. Calculates variance in dollars and percentage, flags lines exceeding alert thresholds. Food & Dining shows the largest relative over-performance at 1,017.77%.

`category_line_item` · `budgeted_amount` · `actual_amount` · `variance_dollars` · `variance_pct` · `operational_status`

![Budget Variance Analysis](<Screenshots/Screenshot 2026-06-02 143119.png>)

---

### 04 — Portfolio exposure & geographic risk
Measures capital concentration across Canadian provinces using weighted allocation percentages and a normalized risk profile score. Ontario (39.3%) and Quebec (22.6%) are the dominant nodes. All provinces track within a balanced risk band around the mean of 50.00.

`asset_node` · `provincial_asset_volume` · `asset_allocation_count` · `allocation_weight_pct` · `weighted_risk_profile` · `risk_tier`

![Portfolio Performance & Exposure Risk](<Screenshots/Screenshot 2026-06-02 143155.png>)

---

### 05 — Velocity fraud & AML detection
Flags two fraud patterns: card-skimming velocity attacks (rapid sequential transactions for the same customer using `LAG() OVER PARTITION BY` with `INTERVAL` deltas) and network duplicate retry payloads (distinct UUIDs with identical client, timestamp, and amount — `time_lapse = 00:00:00`).

`customer_id` · `transaction_id` · `first_swipe` · `rapid_followup_swipe` · `prior_transaction_amount` · `current_transaction_amount` · `time_lapse`

![Risk & Velocity Fraud Detection](<Screenshots/Screenshot 2026-06-02 143223.png>)

---

### 06 — Cohort retention matrix
Tracks yearly registration cohorts and measures what percentage remain active at Year 1, Year 2, and Year 3. NULL values correctly appear for 2024–2026 cohorts where the full time horizon hasn't elapsed — this is intentional, not missing data.

`cohort_year` · `initial_size` · `year_1_retention_pct` · `year_2_retention_pct` · `year_3_retention_pct`

![User Cohort Retention Matrix](<Screenshots/Screenshot 2026-06-02 143256.png>)

---

### 07 — Pareto wealth distribution
Calculates running cumulative revenue contribution across the user population, ranked by spend. The top 100 users (0.33% of base) contribute just 0.51% of revenue — indicating a healthy, non-concentrated revenue distribution without systemic whale dependency.

`top_n_users` · `population_percentile_pct` · `user_cutoff_spend` · `cumulative_revenue_contribution_pct`

![Pareto Wealth Contribution](<Screenshots/Screenshot 2026-06-02 143318.png>)

---

### 08 — Dormant user recovery
Identifies high-value accounts silent for 90+ days using `CURRENT_DATE` arithmetic. Outputs a prioritized reactivation list ranked by lost lifetime value — giving a marketing or CRM team an immediately actionable dataset.

`customer_id` · `email` · `province` · `historic_transaction_count` · `lost_lifetime_value` · `last_active_date` · `days_dormant`

![Dormant User Recovery Attribution](<Screenshots/image.png>)

---

## Project structure

```text
financial_sql_portfolio/
│
├── data_generation/
│   ├── dataset/
│   │   ├── customers.csv
│   │   └── transactions.csv
│   └── datagen.py                         # 2.3M+ rows with seasonality and intentional bugs
│
├── sql_queries/
│   ├── 01_schema_setup.sql                # Raw tables DDL + yearly range partitions
│   ├── 02_indexing_raw.sql                # Post-ingestion integrity checks
│   ├── 03_fact_dim_tables.sql             # Star schema ETL pipeline
│   ├── 04_cleaned_transactions_table.sql  # Cleaning mart
│   ├── 05_indexing_fact_dim_tables.sql    # Analytical query index layer
│   └── insights/
│       ├── 01_financial_performance.sql
│       ├── 02_customer_transaction.sql
│       ├── 03_budget_variance.sql
│       ├── 04_portfolio_performance.sql
│       ├── 05_risk_fraud_detection.sql
│       ├── 06_cohort_retention.sql
│       ├── 07_pareto_whale_analysis.sql
│       └── 08_dormant_user_attribution.sql
│
├── Screenshots/
├── requirements.txt
└── README.md
```

---

## Setup

```bash
git clone https://github.com/yourusername/financial_sql_portfolio
cd financial_sql_portfolio
pip install -r requirements.txt

# Generate the dataset
python data_generation/datagen.py

# In PostgreSQL / DBeaver — run in order:
# 1. sql_queries/01_schema_setup.sql
# 2. sql_queries/02_indexing_raw.sql
# 3. sql_queries/03_fact_dim_tables.sql
# 4. sql_queries/04_cleaned_transactions_table.sql
# 5. sql_queries/05_indexing_fact_dim_tables.sql
# Then run any insights/ script
```

---

## Stack

| Tool | Purpose |
| :--- | :--- |
| Python 3 | Data generation, ETL scripting |
| pandas / numpy / Faker | Synthetic data with realistic distributions |
| PostgreSQL | Analytical warehouse |
| DBeaver | Query execution and schema management |
| SQL (advanced) | Window functions, CTEs, partitioning, date arithmetic |