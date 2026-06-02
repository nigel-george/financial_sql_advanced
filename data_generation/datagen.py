import os
import sys
import uuid
import numpy as np
import pandas as pd
from faker import Faker
from datetime import datetime

def main():
    np.random.seed(42)
    fake = Faker()

    current_dir = os.path.dirname(os.path.abspath(__file__))
    target_dir = os.path.join(current_dir, 'dataset')
    os.makedirs(target_dir, exist_ok=True)
    
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] INFO: Initializing Canadian financial data generation pipeline.")

    end_date = datetime.now().strftime('%Y-%m-%d')
    start_date = (datetime.now() - pd.DateOffset(years=5)).strftime('%Y-%m-%d')
    all_dates = pd.date_range(start=start_date, end=end_date, freq='D')
    
    total_customers = 30000
    base_transactions = 2300000

    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] INFO: Configuration loaded. Timeline: {start_date} to {end_date} ({len(all_dates)} days).")

    # Generate Customers Dimension
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] INFO: Generating {total_customers} customer profiles.")
    
    customer_ids = [str(uuid.uuid4()) for _ in range(total_customers)]
    signup_dates = np.random.choice(all_dates, size=total_customers)
    
    provinces = ['ON', 'QC', 'BC', 'AB', 'MB', 'SK', 'NS', 'NB', 'NL', 'PE']
    prov_weights = [0.39, 0.23, 0.14, 0.12, 0.04, 0.03, 0.02, 0.02, 0.007, 0.003]
    assigned_provinces = np.random.choice(provinces, size=total_customers, p=prov_weights)
    risk_scores = np.random.randint(1, 100, size=total_customers)
    
    customer_emails = [fake.unique.free_email() for _ in range(total_customers)]

    customer_phones = []
    for _ in range(total_customers):
        rand_val = np.random.rand()
        if rand_val < 0.10:
            customer_phones.append(None)
        elif rand_val < 0.15:
            customer_phones.append(fake.numerify(text='+1-###-###-####'))
        elif rand_val < 0.20:
            customer_phones.append(fake.numerify(text='(###) ###-####'))
        else:
            customer_phones.append(fake.numerify(text='###-###-####'))

    df_customers = pd.DataFrame({
        'customer_id': customer_ids,
        'account_created_date': sorted(signup_dates),
        'email': customer_emails,
        'phone_number': customer_phones,
        'province': assigned_provinces,
        'risk_score': risk_scores
    })

    # Generate Transactions Fact
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] INFO: Generating {base_transactions} core transaction logs.")
    
    tx_ids = [str(uuid.uuid4()) for _ in range(base_transactions)]
    
    unique_years = sorted(list(set(all_dates.year)))
    year_scales = np.linspace(0.5, 1.7, len(unique_years))
    year_w_map = dict(zip(unique_years, year_scales))

    master_weights = []
    for d in all_dates:
        day_w = 1.7 if d.weekday() == 5 else (1.4 if d.weekday() == 4 else (1.3 if d.weekday() == 6 else 1.0))
        month_w = 1.8 if d.month in [11, 12] else (0.6 if d.month in [1, 2] else 1.0)
        year_w = year_w_map.get(d.year, 1.0)
        master_weights.append(day_w * month_w * year_w)
        
    probabilities = np.array(master_weights) / sum(master_weights)
    chosen_tx_dates = np.random.choice(all_dates, size=base_transactions, p=probabilities)
    chosen_tx_dates = sorted(chosen_tx_dates)

    assigned_cust_ids = np.random.choice(customer_ids, size=base_transactions)
    tx_amounts = np.round(np.random.exponential(scale=65.0, size=base_transactions) + 4.50, 2)
    
    categories_pool = [
        'Retail', 'RETAIL', 'retail',
        'Food & Dining', 'FOOD & DINING', 'food & dining',
        'Utilities', 'UTILITIES', 'utilities',
        'Travel & Entertainment', 'TRAVEL & ENTERTAINMENT',
        'Investment Tranche'
    ]
    pool_weights = [0.15, 0.15, 0.10, 0.15, 0.10, 0.10, 0.05, 0.05, 0.02, 0.05, 0.05, 0.03]
    assigned_categories = np.random.choice(categories_pool, size=base_transactions, p=pool_weights)

    df_transactions = pd.DataFrame({
        'transaction_id': tx_ids,
        'customer_id': assigned_cust_ids,
        'transaction_date': chosen_tx_dates,
        'amount': tx_amounts,
        'category': assigned_categories
    })

    # Structural duplicate injection
    num_duplicates = 2300
    dup_indices = np.random.choice(base_transactions, size=num_duplicates, replace=False)
    
    df_duplicates = df_transactions.iloc[dup_indices].copy()
    df_duplicates['transaction_id'] = [str(uuid.uuid4()) for _ in range(num_duplicates)]
    
    df_transactions = pd.concat([df_transactions, df_duplicates]).sort_values('transaction_date').reset_index(drop=True)
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] INFO: Injected {num_duplicates} structural duplicate rows into transaction ledger.")

    # Disk Target Outputs
    cust_path = os.path.join(target_dir, 'customers.csv')
    tx_path = os.path.join(target_dir, 'transactions.csv')
    
    df_customers.to_csv(cust_path, index=False)
    df_transactions.to_csv(tx_path, index=False)
    
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] SUCCESS: Exported customers table  ({df_customers.shape[0]} rows).")
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] SUCCESS: Exported transactions table  ({df_transactions.shape[0]} rows).")

if __name__ == "__main__":
    main()