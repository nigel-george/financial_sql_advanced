# Canadian Financial Data Warehouse & Analytics Platform Using SQL

An end-to-end data engineering project that simulates a production financial platform. This repository handles data generation, relational warehouse schema design, ETL data cleaning pipelines, and modular financial analytics using **Python (Pandas)** and **PostgreSQL**.

The pipeline simulates over 2.3 million raw consumer transactions, cleans structural formatting issues, organizes them into a Star Schema data mart, and runs advanced queries targeting performance metrics, customer cohort retention, and fraud patterns.

---

## Architecture & Design Choices
* **Data Generation:** Python 3, Pandas, NumPy, Faker
* **Database:** PostgreSQL (Managed via DBeaver)
* **Key Strategy:** Cryptographic UUIDs (V4) used natively for both customer and transaction records to mimic modern distributed systems.
* **Optimization:** Range partitioning by calendar year, explicit dimension/fact modeling, and targeted B-Tree indexing.

---

## Project Analytics Summary

The data mart drives 8 distinct analytical business tracks. Below is a breakdown of the core metrics tracked and the advanced SQL strategies implemented in each module:

| Script | Business Domain | Key Metrics Calculated | SQL Mechanics Utilized |
| :--- | :--- | :--- | :--- |
| **01_financial_performance** | Corporate Finance | Gross Revenue, MoM Absolute & % Growth Rates | `DATE_TRUNC`, `LAG()`, Rolling 3-Month Moving Average (`ROWS BETWEEN`) |
| **02_customer_transaction** | CRM Strategy | Lifetime Value (LTV), Average Ticket Size, Recency | `DENSE_RANK()`, Multi-table `INNER JOIN`, Conditional `CASE WHEN` Segmentation |
| **03_budget_variance** | FP&A Operations | Budget vs. Actual Dollars, Variance % Thresholds | Dynamic CTE Matrix (`VALUES` constructor), `LEFT JOIN` Aggregation |
| **04_portfolio_performance**| Risk & Exposure | Capital Weighting %, Weighted Provincial Risk Profiles | Statistical Window Aggregates (`SUM() OVER ()`), Structural Sorting |
| **05_risk_fraud_detection** | Fraud / AML | Card-Skimming Velocity Attacks, Network Payload Duplicates | Chronological `LAG() OVER (PARTITION BY)`, Time Interval Deltas (`INTERVAL`) |
| **06_cohort_retention** | Product Growth | Yearly Registration Cohort Inactivity & Retention Curves | Year String Parsing, Multi-Year Conditional Matrix Aggregation, `LEAST` Safety Cap |
| **07_pareto_whale_analysis**| Macro Economics | Running Total Cumulative Weights, Population Percentiles | `ROW_NUMBER() OVER`, Running Totals vs. Global Aggregates |
| **08_dormant_user** | Revenue Recovery | High-Value Account Churn, Recency Boundaries, Lost Value | Multi-Table `INNER JOIN`, Current Date Arithmetic (`CURRENT_DATE - timestamp`) |

---

## Data Validation & Deep Insights

### 01 Financial Performance Analysis
* **Core Discovery:** Tracks top-line revenue velocity. The data surfaces a massive mid-year truncation anomaly in June 2026 ($224K vs. May's $4.1M) representing the active partial month, while demonstrating steady baseline traction rolling through 2024 and 2025.
* **Output Matrix:** `fiscal_period` | `gross_revenue` | `volume_count` | `absolute_growth` | `mom_growth_pct` | `smoothed_trend_revenue`

![Financial Performance Analysis](<Screenshots/Screenshot 2026-06-02 143012.png>)

### 02 Customer Transaction Profiling
* **Core Discovery:** Isolates the top 20 highest-value "whale" accounts out of 30,000 users. The highest LTV user sits at $8,924.06 with 103 transactions and a highly active recency window (last active 4 days ago), successfully mapping power users vs. active standard accounts.
* **Output Matrix:** `whale_rank` | `customer_id` | `province` | `lifetime_transaction_count` | `lifetime_value_ltv` | `average_ticket_size` | `days_since_last_active` | `lifecycle_segment`

![Customer Transaction Profiling](<Screenshots/Screenshot 2026-06-02 143052.png>)

### 03 Budget Variance Analysis
* **Core Discovery:** Mocks an FP&A corporate target tracker. Due to explosive platform growth, all primary lines over-performed baseline targets significantly. Retail generated the highest absolute variance ($56.9M over budget), while Food & Dining registered the highest relative scale at 1,017.77% over budget.
* **Output Matrix:** `category_line_item` | `budgeted_amount` | `actual_amount` | `variance_dollars` | `variance_pct` | `operational_status`

![Budget Variance Analysis](<Screenshots/Screenshot 2026-06-02 143119.png>)

### 04 Portfolio Performance & Exposure Risk
* **Core Discovery:** Analyzes geographical capital concentration across Canadian provinces. Ontario (ON) represents the largest risk node holding 39.33% of asset volume ($62.8M across 904K transactions), followed by Quebec (QC) at 22.58%. Risk exposure remains highly balanced across all nodes, tracking closely to a mean score of 50.00.
* **Output Matrix:** `asset_node` | `provincial_asset_volume` | `asset_allocation_count` | `allocation_weight_pct` | `weighted_risk_profile` | `risk_tier`

![Portfolio Performance & Exposure Risk](<Screenshots/Screenshot 2026-06-02 143155.png>)

### 05 Risk & Velocity Fraud Detection
* **Core Discovery:** Successfully uncovers simulated network duplicate retry payloads hiding in the 2.3 million records. The query flags rapid sequence events where distinct transaction UUIDs occur for the exact same client, timestamp, and asset values, resulting in a `time_lapse` of exactly `00:00:00`.
* **Output Matrix:** `customer_id` | `transaction_id` | `first_swipe` | `rapid_followup_swipe` | `prior_transaction_amount` | `current_transaction_amount` | `time_lapse`

![Risk & Velocity Fraud Detection](<Screenshots/Screenshot 2026-06-02 143223.png>)

### 06 User Cohort Retention Matrix
* **Core Discovery:** Measures platform stickiness. Because user transaction dates are generated across a 5-year uniform continuum, retention rates hold highly stable at ~100% across early lifecycles. Truncated `[NULL]` fields correctly surface for late-stage cohorts (2024–2026) where time horizons haven't elapsed yet.
* **Output Matrix:** `cohort_year` | `initial_size` | `year_1_retention_pct` | `year_2_retention_pct` | `year_3_retention_pct`

![User Cohort Retention Matrix](<Screenshots/Screenshot 2026-06-02 143256.png>)

### 07 Pareto Wealth Contribution
* **Core Discovery:** Evaluates revenue distribution density. The platform displays a healthy, diversified revenue layout rather than a severe systemic bottleneck: the top 100 users contribute just 0.51% of gross revenue, the top 10% contribute 12.86%, and the top 50% (15,000 users) account for 56.2% of total cumulative value.
* **Output Matrix:** `top_n_users` | `population_percentile_pct` | `user_cutoff_spend` | `cumulative_revenue_contribution_pct`

![Pareto Wealth Contribution](<Screenshots/Screenshot 2026-06-02 143318.png>)

### 08 Dormant User Recovery Attribution
* **Core Discovery:** Targets high-value accounts that have gone completely dark for over 90 days. The script isolates users like `shawnlowery@yahoo.com` in Quebec, who represents $7,244.73 in lost customer lifetime value after going cold for 94 days, generating clean data lists for reactive marketing outlays.
* **Output Matrix:** `customer_id` | `email` | `province` | `historic_transaction_count` | `lost_lifetime_value` | `last_active_date` | `days_dormant`

![Dormant User Recovery Attribution](<Screenshots/image.png>)

---

## Project Structure

```text
financial_sql_portfolio/
│
├── data_generation/
│   ├── dataset/
│   │   ├── customers.csv
│   │   └── transactions.csv
│   └── datagen.py                    # Simulates 2.3M+ records with seasonality and bugs
├── env/
├── Screenshots/│
├── sql_queries/
│   ├── 01_schema_setup.sql          # Raw tables DDL and yearly range partitions
│   ├── 02_indexing_raw.sql          # Post-ingestion row count and integrity checks
│   ├── 03_fact_dim_tables.sql    # Transformed Star Schema data mart & ETL pipeline
│   ├── 04_cleaned_transactions_table.sql # Cleaning Mart Table
│   ├── 05_indexing_fact_dim_tables.sql # Core indexing layer for analytical queries
│   └── insights/                    # Production SQL scripts broken out by business domain
│       ├── 01_financial_performance.sql
│       ├── 02_customer_transaction.sql
│       ├── 03_budget_variance.sql
│       ├── 04_portfolio_performance.sql
│       ├── 05_risk_fraud_detection.sql
│       ├── 06_cohort_retention.sql
│       ├── 07_pareto_whale_analysis.sql
│       └── 08_dormant_user_attribution.sql
│
├── requirements.txt
└── README.md