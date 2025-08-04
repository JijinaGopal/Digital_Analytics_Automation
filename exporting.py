import os
import pandas as pd
import pyodbc

# Set export folder
export_dir = r"C:\Users\Administrator\Desktop\Automation\cleaned_data"
os.makedirs(export_dir, exist_ok=True)

# Connect to SQL Server
conn = pyodbc.connect(
    'DRIVER={SQL Server};'
    'SERVER=LAPTOP-2K6MH8QU\SQLEXPRESS;'
    'DATABASE=E_Commerce_Project;'
    'Trusted_Connection=yes;'
)

# List of final tables to export
tables = [
    "orders",
    "order_items",
    "order_item_refunds",
    "products",
    "website_sessions",
    "website_pageviews"
]

# Export each table
for table in tables:
    df = pd.read_sql(f"SELECT * FROM {table}", conn)
    output_path = os.path.join(export_dir, f"{table}.csv")
    df.to_csv(output_path, index=False)
    print(f"✅ Exported: {output_path}")

conn.close()
