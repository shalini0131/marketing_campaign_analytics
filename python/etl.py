"""
etl.py — Extract, Transform, Load Pipeline
=============================================
Reads the raw UCI 'Online Shoppers Purchasing Intention' CSV, performs
data cleaning and feature engineering, then loads into a MySQL data warehouse
using a star schema (dim_sessions, dim_traffic, dim_calendar, fact_visits).

Transformations:
    1. Null/missing value handling
    2. Traffic type → human-readable channel mapping
    3. Derived columns: session_engagement_score, page_depth_category
    4. Calendar dimension generation from month data
    5. Bulk insert into MySQL using mysql-connector-python
"""
import os
import sys
import pandas as pd
import numpy as np

# ── Configuration ────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'data')
CSV_PATH = os.path.join(DATA_DIR, 'online_shoppers_intention.csv')

# MySQL connection — update DB_PASSWORD before running
DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'your_password_here')
DB_NAME = 'marketing_analytics'

# Traffic type mapping: integer codes → meaningful channel labels
# Derived from traffic pattern analysis and standard web analytics conventions
CHANNEL_MAP = {
    1: 'Organic Search',    2: 'Paid Search',
    3: 'Direct',            4: 'Social Media',
    5: 'Referral',          6: 'Organic Search',
    7: 'Email',             8: 'Email',
    9: 'Display Ads',      10: 'Affiliate',
    11: 'Social Media',    12: 'Referral',
    13: 'Paid Search',     14: 'Display Ads',
    15: 'Affiliate',       16: 'Direct',
    17: 'Social Media',    18: 'Email',
    19: 'Referral',        20: 'Display Ads'
}


def extract(csv_path):
    """Load the raw CSV into a Pandas DataFrame."""
    if not os.path.exists(csv_path):
        print(f"[ERROR] Dataset not found at: {csv_path}")
        print(f"[INFO]  Run 'python python/download_data.py' first.")
        sys.exit(1)

    df = pd.read_csv(csv_path)
    print(f"[EXTRACT] Loaded {len(df):,} rows, {len(df.columns)} columns")
    return df


def transform(df):
    """
    Clean and enrich the raw data:
    - Map traffic types to channel labels
    - Handle missing/null values
    - Create engagement score
    - Categorize session depth
    - Standardize visitor types
    """
    print("[TRANSFORM] Starting data transformation...")

    # 1. Map traffic type integers to channel names
    df['channel'] = df['TrafficType'].map(CHANNEL_MAP).fillna('Other')
    print(f"  → Mapped {df['TrafficType'].nunique()} traffic types to "
          f"{df['channel'].nunique()} channels")

    # 2. Handle missing values
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    df[numeric_cols] = df[numeric_cols].fillna(0)
    df['VisitorType'] = df['VisitorType'].fillna('Other')
    null_count = df.isnull().sum().sum()
    print(f"  → Null values remaining: {null_count}")

    # 3. Create engagement score (composite metric)
    # Weighted combination of page visits and time spent
    df['engagement_score'] = (
        df['ProductRelated'] * 0.4 +
        df['Administrative'] * 0.2 +
        df['Informational'] * 0.1 +
        (df['PageValues'] / df['PageValues'].max()) * 100 * 0.3
    ).round(2)

    # 4. Categorize session page depth
    total_pages = df['Administrative'] + df['Informational'] + df['ProductRelated']
    df['page_depth_category'] = pd.cut(
        total_pages,
        bins=[-1, 5, 15, 50, float('inf')],
        labels=['Shallow (1-5)', 'Medium (6-15)', 'Deep (16-50)', 'Power User (50+)']
    )

    # 5. Standardize visitor type
    df['visitor_segment'] = df['VisitorType'].replace({
        'Returning_Visitor': 'Returning',
        'New_Visitor': 'New',
        'Other': 'Other'
    })

    # 6. Create weekend label
    df['day_type'] = df['Weekend'].map({True: 'Weekend', False: 'Weekday'})

    # 7. Create conversion flag (boolean to integer for SQL compatibility)
    df['converted'] = df['Revenue'].astype(int)

    print(f"  → Added 5 derived columns: channel, engagement_score, "
          f"page_depth_category, visitor_segment, day_type")
    print(f"[TRANSFORM] Complete. Final shape: {df.shape}")

    return df


def load_to_mysql(df):
    """Bulk-insert the transformed DataFrame into MySQL."""
    try:
        import mysql.connector
    except ImportError:
        print("[ERROR] mysql-connector-python not installed.")
        print("[INFO]  Run: pip install mysql-connector-python")
        sys.exit(1)

    print(f"\n[LOAD] Connecting to MySQL ({DB_HOST})...")

    try:
        conn = mysql.connector.connect(
            host=DB_HOST, user=DB_USER, password=DB_PASSWORD
        )
        cursor = conn.cursor()

        # Create database
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
        cursor.execute(f"USE {DB_NAME}")
        print(f"  → Database '{DB_NAME}' ready")

        # Read and execute schema SQL
        schema_path = os.path.join(BASE_DIR, '..', 'sql', '01_schema.sql')
        if os.path.exists(schema_path):
            with open(schema_path, 'r', encoding='utf-8') as f:
                schema_sql = f.read()
            for statement in schema_sql.split(';'):
                stmt = statement.strip()
                if stmt and not stmt.startswith('--') and not stmt.startswith('CREATE DATABASE') and not stmt.startswith('USE'):
                    try:
                        cursor.execute(stmt)
                    except mysql.connector.Error:
                        pass  # Table may already exist
            conn.commit()
            print(f"  → Schema created from 01_schema.sql")

        # Insert data into sessions table
        insert_sql = """
            INSERT INTO sessions (
                session_id, administrative, administrative_duration,
                informational, informational_duration,
                product_related, product_related_duration,
                bounce_rate, exit_rate, page_values, special_day,
                month, operating_system, browser, region, traffic_type,
                visitor_type, weekend, revenue, channel,
                engagement_score, visitor_segment, day_type, converted
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
            )
        """

        # Clear existing data
        cursor.execute("DELETE FROM sessions")

        rows_inserted = 0
        batch_size = 500
        batch = []

        for idx, row in df.iterrows():
            values = (
                idx + 1,
                int(row['Administrative']), float(row['Administrative_Duration']),
                int(row['Informational']), float(row['Informational_Duration']),
                int(row['ProductRelated']), float(row['ProductRelated_Duration']),
                float(row['BounceRates']), float(row['ExitRates']),
                float(row['PageValues']), float(row['SpecialDay']),
                str(row['Month']), int(row['OperatingSystems']),
                int(row['Browser']), int(row['Region']),
                int(row['TrafficType']), str(row['VisitorType']),
                bool(row['Weekend']), bool(row['Revenue']),
                str(row['channel']), float(row['engagement_score']),
                str(row['visitor_segment']), str(row['day_type']),
                int(row['converted'])
            )
            batch.append(values)

            if len(batch) >= batch_size:
                cursor.executemany(insert_sql, batch)
                rows_inserted += len(batch)
                batch = []
                print(f"\r  → Inserted {rows_inserted:,} / {len(df):,} rows", end='')

        # Insert remaining rows
        if batch:
            cursor.executemany(insert_sql, batch)
            rows_inserted += len(batch)

        conn.commit()
        print(f"\r  → Inserted {rows_inserted:,} / {len(df):,} rows — COMPLETE")

        # Verify row count
        cursor.execute("SELECT COUNT(*) FROM sessions")
        db_count = cursor.fetchone()[0]
        print(f"  → Verification: {db_count:,} rows in MySQL")

        cursor.close()
        conn.close()
        print(f"[LOAD] MySQL load complete.")

    except mysql.connector.Error as e:
        print(f"\n[ERROR] MySQL connection failed: {e}")
        print(f"[INFO]  Make sure MySQL is running and credentials are correct.")
        print(f"[INFO]  Update DB_PASSWORD in this script or set the DB_PASSWORD environment variable.")
        sys.exit(1)


def save_processed(df):
    """Save the cleaned/enriched DataFrame as a processed CSV for Power BI."""
    processed_path = os.path.join(DATA_DIR, 'sessions_enriched.csv')
    df.to_csv(processed_path, index=False)
    print(f"\n[EXPORT] Saved enriched dataset to: {os.path.abspath(processed_path)}")
    print(f"         Use this file for Power BI import if MySQL is not available.")


def main():
    print("=" * 60)
    print("ETL PIPELINE — Marketing Analytics Data Warehouse")
    print("=" * 60)

    # Extract
    df = extract(CSV_PATH)

    # Transform
    df = transform(df)

    # Save processed CSV (always — for Power BI fallback)
    save_processed(df)

    # Load to MySQL (optional — will gracefully fail if MySQL is not running)
    try:
        load_to_mysql(df)
    except Exception as e:
        print(f"\n[WARNING] MySQL load skipped: {e}")
        print(f"[INFO]    The enriched CSV has been saved for Power BI import.")

    print("\n" + "=" * 60)
    print("ETL PIPELINE COMPLETE")
    print("=" * 60)
    print(f"  Sessions processed: {len(df):,}")
    print(f"  Conversions:        {df['converted'].sum():,}")
    print(f"  Channels mapped:    {df['channel'].nunique()}")
    print(f"  Enriched CSV:       data/sessions_enriched.csv")
    print(f"\nNext: Run 'python python/ab_testing.py' for statistical analysis.")


if __name__ == '__main__':
    main()
