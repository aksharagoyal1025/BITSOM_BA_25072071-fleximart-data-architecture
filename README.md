# FlexiMart Data Architecture Project

**Student Name:** AKSHARA GOYAL  
**Student ID:** BITSOM_BA_25072071  
**Email:** aksharagoyal1025@gmail.com 
**Date:** 02 Jan 2026  

## Project Overview

This project builds a complete data architecture for the FlexiMart retail store. It covers an ETL pipeline into a relational database, a NoSQL product catalog in MongoDB, and a sales data warehouse with OLAP queries for analytics.

## Repository Structure

├── data 
│   ├── customers_raw.csv  
│   ├── products_raw.csv  
│   └── sales_raw.csv  
├── part1-database-etl
│   ├── etl_pipeline.py  
│   ├── schema_documentation.md  
│   ├── business_queries.sql  
│   └── data_quality_report.txt  
├── part2-nosql
│   ├── nosql_analysis.md  
│   ├── mongodb_operations.js  
│   └── products_catalog.json  
├── part3-datawarehouse/  
│   ├── star_schema_design.md  
│   ├── warehouse_schema.sql  
│   ├── warehouse_data.sql  
│   └── analytics_queries.sql  
└── README.md  

## Technologies Used

- Python 3, pandas, mysql-connector-python  
- MySQL 8.0 (operational DB + data warehouse)  
- MongoDB 6.0 for document store

## Setup Instructions

### Database Setup

```bash
# Create databases
mysql -u root -p -e "CREATE DATABASE fleximart;"
mysql -u root -p -e "CREATE DATABASE fleximart_dw;"

# Run Part 1 - ETL Pipeline
python part1-database-etl/etl_pipeline.py

# Run Part 1 - Business Queries
mysql -u root -p fleximart < part1-database-etl/business_queries.sql

# Run Part 2 - MongoDB (NoSQL)
mongosh < part2-nosql/mongodb_operations.js

# Run Part 3 - Data Warehouse
mysql -u root -p fleximart_dw < part3-datawarehouse/warehouse_schema.sql
mysql -u root -p fleximart_dw < part3-datawarehouse/warehouse_data.sql
mysql -u root -p fleximart_dw < part3-datawarehouse/analytics_queries.sql
- Test commit for practice