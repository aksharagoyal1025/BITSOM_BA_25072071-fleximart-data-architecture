import pandas as pd
import mysql.connector
from mysql.connector import Error

# ========== 1. MySQL CONFIG ==========
DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",           # <- change if needed
    "password": "MySQL@1025", # <- your password
    "database": "fleximart",
}

# ========== 2. CONNECT ==========
def get_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        if conn.is_connected():
            print(" Connected to MySQL")
            return conn
    except Error as e:
        print(" MySQL connection error:", e)
        raise
    raise RuntimeError("Could not connect to MySQL")

# ========== 3. LOAD CSVs ==========

def load_customers_csv(path="customers_raw.csv"):
    df = pd.read_csv(path)
    total_customers_raw = len(df)

    df.columns = df.columns.str.strip()
    df = df[["customer_id", "first_name", "last_name", "email", "phone"]]

    for col in ["customer_id", "first_name", "last_name", "email", "phone"]:
        df[col] = df[col].astype(str).str.strip()

    missing_customers_before = df.isnull().sum().sum()

    df = df.where(pd.notnull(df), None)

    dup_customers_removed = df.duplicated(subset=["customer_id"]).sum()
    df = df.drop_duplicates(subset=["customer_id"])

    return df, total_customers_raw, dup_customers_removed, missing_customers_before

def load_products_csv(path="products_raw.csv"):
    df = pd.read_csv(path)
    total_products_raw = len(df)

    df.columns = df.columns.str.strip()

    # normalize category
    df["category"] = (
        df["category"]
        .astype(str)
        .str.strip()
        .str.upper()
    )

    
    df["product_id"] = (
        df["product_id"]
        .astype(str)
        .str.strip()
        .str.replace("P", "", case=False)
    )
    df["product_id"] = pd.to_numeric(df["product_id"], errors="coerce")

    
    df["price"] = pd.to_numeric(df["price"], errors="coerce")
    df["stock_quantity"] = pd.to_numeric(df["stock_quantity"], errors="coerce")

    missing_products_before = df.isnull().sum().sum()

    
    df = df.where(pd.notnull(df), None)

    df = df.dropna(subset=["product_id"])
    df["product_id"] = df["product_id"].astype(int)

    dup_products_removed = df.duplicated(subset=["product_id"]).sum()
    df = df.drop_duplicates(subset=["product_id"])

    return df, total_products_raw, dup_products_removed, missing_products_before

def load_transactions_csv(path="sales_raw.csv"):
    df = pd.read_csv(path)
    total_sales_raw = len(df)

    df.columns = df.columns.str.strip()

    for col in ["transaction_id", "customer_id", "product_id", "status"]:
        df[col] = df[col].astype(str).str.strip()

    missing_sales_before = df.isnull().sum().sum()

    df["transaction_date"] = pd.to_datetime(
        df["transaction_date"],
        errors="coerce",
        dayfirst=True,
    )  
    df = df[df["transaction_date"].notna()]
    df["transaction_date"] = df["transaction_date"].dt.date

    df["quantity"] = pd.to_numeric(df["quantity"], errors="coerce").fillna(0).astype(int)
    df["unit_price"] = pd.to_numeric(df["unit_price"], errors="coerce")

    
    df = df[(df["customer_id"] != "") & (df["product_id"] != "")]
    df = df[df["customer_id"].notna() & df["product_id"].notna()]


    df["order_id"] = df["transaction_id"].str.replace("T", "", case=False)
    df["order_id"] = pd.to_numeric(df["order_id"], errors="coerce")
    df = df[df["order_id"].notna()]
    df["order_id"] = df["order_id"].astype(int)

    
    df["product_id_clean"] = df["product_id"].str.replace("P", "", case=False)
    df["product_id_clean"] = pd.to_numeric(df["product_id_clean"], errors="coerce")
    df = df[df["product_id_clean"].notna()]
    df["product_id_clean"] = df["product_id_clean"].astype(int)

    df = df.where(pd.notnull(df), None)

    dup_sales_removed = df.duplicated(subset=["transaction_id"]).sum()
    df = df.drop_duplicates(subset=["transaction_id"])

    return (
        df,
        total_sales_raw,
        dup_sales_removed,
        missing_sales_before,
    )

# ========== 4. LOAD INTO TABLES ==========

def upsert_customers(conn, customers_df):
    cursor = conn.cursor()
    sql = """
        INSERT INTO customers (customer_id, first_name, last_name, email, phone)
        VALUES (%s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            first_name = VALUES(first_name),
            last_name = VALUES(last_name),
            email = VALUES(email),
            phone = VALUES(phone)
    """
    rows = []
    for _, row in customers_df.iterrows():
        email = row["email"]
        if email in (None, "", "nan", "NaN"):
            email = "" 
        rows.append(
            (
                row["customer_id"],
                row["first_name"],
                row["last_name"],
                email,
                row["phone"],
            )
        )
    if rows:
        cursor.executemany(sql, rows)
        conn.commit()
        print(f"customers upserted: {cursor.rowcount}")
    cursor.close()

def upsert_products(conn, products_df):
    cursor = conn.cursor()

    
    products_df = products_df.replace(["nan", "NaN", "None"], pd.NA)

    
    products_df = products_df.where(pd.notnull(products_df), None)

    sql = """
        INSERT INTO products (product_id, product_name, category, price, stock_quantity)
        VALUES (%s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            product_name = VALUES(product_name),
            category = VALUES(category),
            price = VALUES(price),
            stock_quantity = VALUES(stock_quantity)
    """

    rows = []
    for _, row in products_df.iterrows():
        product_id = int(row["product_id"])

        product_name = row["product_name"]
        category = row["category"]

        price = row["price"]
        if price is None or pd.isna(price):
            price = 0.0  
        else:
            price = float(price)

        stock_qty = row["stock_quantity"]
        if stock_qty is None or pd.isna(stock_qty):
            stock_qty = 0
        else:
            stock_qty = int(stock_qty)

        rows.append((product_id, product_name, category, price, stock_qty))

    if rows:
        cursor.executemany(sql, rows)
        conn.commit()
        print(f"products upserted: {cursor.rowcount}")

    cursor.close()

def insert_orders_and_items(conn, tx_df):
    cursor = conn.cursor()

    
    cursor.execute("SELECT customer_id FROM customers")
    valid_customers = {str(row[0]).strip() for row in cursor.fetchall()}

    
    tx_df["customer_id"] = tx_df["customer_id"].astype(str).str.strip()
    tx_df = tx_df[tx_df["customer_id"].isin(valid_customers)]

    
    orders_df = tx_df[["order_id", "customer_id",
                       "transaction_date", "status", "quantity", "unit_price"]].copy()
    orders_df["total_amount"] = orders_df["quantity"] * orders_df["unit_price"]
    orders_df = orders_df.drop_duplicates(subset=["order_id"])

    orders_sql = """
        INSERT INTO orders (order_id, customer_id, order_date, total_amount, status)
        VALUES (%s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            customer_id = VALUES(customer_id),
            order_date = VALUES(order_date),
            total_amount = VALUES(total_amount),
            status = VALUES(status)
    """

    order_rows = []
    for _, row in orders_df.iterrows():
        total_amount = row["total_amount"]
        if total_amount is None or pd.isna(total_amount):
            total_amount = 0.0
        else:
            total_amount = float(total_amount)

        order_rows.append(
            (
                int(row["order_id"]),
                row["customer_id"],          
                row["transaction_date"],
                total_amount,
                row["status"],
            )
        )

    if order_rows:
        cursor.executemany(orders_sql, order_rows)
        conn.commit()
        print(f"orders upserted: {cursor.rowcount}")

    
    items_sql = """
        INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, subtotal)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            order_id = VALUES(order_id),
            product_id = VALUES(product_id),
            quantity = VALUES(quantity),
            unit_price = VALUES(unit_price),
            subtotal = VALUES(subtotal)
    """

    item_rows = []
    for idx, row in tx_df.iterrows():
        order_id = int(row["order_id"])
        product_id = int(row["product_id_clean"])
        quantity = int(row["quantity"])

        unit_price = row["unit_price"]
        if unit_price is None or pd.isna(unit_price):
            unit_price = 0.0
        else:
            unit_price = float(unit_price)

        order_item_id = order_id * 1000 + (idx + 1)

        subtotal = quantity * unit_price
        item_rows.append(
            (order_item_id, order_id, product_id, quantity, unit_price,subtotal)
        )

    if item_rows:
        cursor.executemany(items_sql, item_rows)
        conn.commit()
        print(f"order_items upserted: {cursor.rowcount}")

    cursor.close()

# ========== 5. MAIN RUNNER ==========

def run_etl():
    conn = None
    try:
        conn = get_connection()

        # ---- Extract & Transform ----
        customers_df, cust_total, cust_dup, cust_missing = load_customers_csv("customers_raw.csv")
        products_df,  prod_total, prod_dup, prod_missing = load_products_csv("products_raw.csv")
        tx_df,        sales_total, sales_dup, sales_missing = load_transactions_csv("sales_raw.csv")

        print("CSVs cleaned and ready")

        # ---- Load ----
        upsert_customers(conn, customers_df)
        upsert_products(conn, products_df)
        insert_orders_and_items(conn, tx_df)

        # ---- Loaded row counts from DB ----
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM customers")
        loaded_customers = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM products")
        loaded_products = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM orders")
        loaded_orders = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM order_items")
        loaded_order_items = cursor.fetchone()[0]
        cursor.close()

        # ---- Data Quality Report ----
        report = f"""
FlexiMart Data Quality Report

Customers:
  Raw records           : {cust_total}
  Duplicates removed    : {cust_dup}
  Missing values (before cleaning, all cols): {cust_missing}
  Records loaded in DB  : {loaded_customers}

Products:
  Raw records           : {prod_total}
  Duplicates removed    : {prod_dup}
  Missing values (before cleaning, all cols): {prod_missing}
  Records loaded in DB  : {loaded_products}

Sales / Transactions:
  Raw records           : {sales_total}
  Duplicates removed    : {sales_dup}
  Missing values (before cleaning, all cols): {sales_missing}
  Orders loaded in DB   : {loaded_orders}
  Order items in DB     : {loaded_order_items}
"""

        with open("data_quality_report.txt", "w", encoding="utf-8") as f:
            f.write(report)

        print(" data_quality_report.txt generated")
        print(" ETL finished successfully")

    except Exception as e:
        print(" ETL failed:", e)
        if conn is not None and conn.is_connected():
            conn.close()
        raise
    finally:
        if conn is not None and conn.is_connected():
            print(" MySQL connection closed")
            conn.close()

if __name__ == "__main__":
    run_etl()
