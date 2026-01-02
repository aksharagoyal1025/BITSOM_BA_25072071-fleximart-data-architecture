# FlexiMart Database Schema Documentation

## Entity: customers

**Purpose:**  
The basic needed details of customers is stored in platform of customers table
**Attributes:**
- customer_id: Integer, primary key, unique id of every customer.
- first_name: Customer's first name , cannot be empty/null.
- last_name: Customer's last name,cannot be empty/null.
- email: Customer's email, unique 
- phone: Customer's phone number, optional.
- city: City of the customer
- registration_date: the date of registration of customer details 

**Relationships:**
- The customer may have multiple orders

## Entity: products

**Purpose:**  
In products table,the basic information of the remaining items on website is stored

**Attributes:**
- product_id: Integer, primary key, unique id of product
- product_name: Product's name, empty/null not allowed.
- category: category of product, no blank.
- price: selling price of product, decimal value, null not allowed
- stock_quantity: stock available, default 0 

**Relationships:**
- A product can be in multiple order through order_items table.

## Entity: orders

**Purpose:**  
Orders table has the summary of all the orders placed by customers.

**Attributes:**
- order_id: Integer, primary key, unbique id every order
- customer_id: Foreign key, gives the information about customer whoplaced the order
- order_date: Date of order
- total_amount: total amount of order
- status: Order current status (Pending, Shipped, Delivered, etc.).

**Relationships:**
- every order is linked to a customer
- one order can have multiple items.

## Entity: order_items

**Purpose:**  
 In Order_items table,the individual items of order are stored 

**Attributes:**
- order_item_id: Integer, primary key, unique id of item
- order_id: Foreign key,items belongs to which order
- product_id: Foreign key,product sold
- quantity: quantity sold 
- unit_price: unit price of every product
- subtotal: quantity × unit_price 

**Relationships:**
- every item is linked to an order and a product.

## Normalization and 3NF

This database is designed using normalization so that data is not repeated too much and is easier to update safely. The main entities (customers, products, orders, and order_items) are stored in separate tables instead of one large table. If everything was kept in a single table, customer name, product name, and price would be copied again on every order line, which would increase the size and make changes more risky.

In first normal form (1NF), each column has a single, simple value. In this schema, columns like phone, city, quantity, and unit_price store only one value and do not contain lists or repeated groups. Second normal form (2NF) removes partial dependencies, so order summary is stored in the orders table, product details are stored in the products table, and order_items only stores the details of each line item. The orders table does not store customer name or city directly; it stores only customer_id to link to the customers table.

In third normal form (3NF), all non‑key attributes depend only on the primary key and not on other non‑key attributes. In the customers table, first_name, last_name, email, phone, and city all depend only on customer_id. In the products table, product_name, category, price, and stock_quantity depend only on product_id. In the orders table, total_amount and status depend only on order_id. In the order_items table, quantity, unit_price, and subtotal depend on the line item key (or the combination of order_id and product_id). Because of this design, update, insert, and delete problems (anomalies) are reduced. For example, if a product price changes, you update it once in the products table instead of changing it in many order rows.

## Sample Data Representation

### customers (sample data)

| customer_id | first_name | last_name | email                | phone         | city    | registration_date |
|------------|------------|-----------|----------------------|---------------|---------|-------------------|
| 1          | Riya       | Sharma    | riya@example.com     | +91-9876543210| Delhi   | 2024-01-10        |
| 2          | Arjun      | Verma     | arjun@example.com    | +91-9876500011| Mumbai  | 2024-02-05        |

### products (sample data)

| product_id | product_name    | category     | price   | stock_quantity |
|-----------|-----------------|--------------|--------:|----------------|
| 1         | Wireless Mouse  | Electronics  | 799.00  | 50             |
| 2         | Running Shoes   | Footwear     | 2499.00 | 30             |

### orders (sample data)

| order_id | customer_id | order_date  | total_amount | status    |
|---------|-------------|------------|-------------:|-----------|
| 1       | 1           | 2024-03-01 | 3298.00      | Delivered |
| 2       | 2           | 2024-03-05 | 799.00       | Shipped   |

### order_items (sample data)

| order_item_id | order_id | product_id | quantity | unit_price | subtotal |
|--------------|----------|-----------|---------:|-----------:|---------:|
| 1            | 1        | 2         | 1        | 2499.00    | 2499.00  |
| 2            | 1        | 1         | 1        | 799.00     | 799.00   |
| 3            | 2        | 1         | 1        | 799.00     | 799.00   |
