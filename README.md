A simple and functional backend system for managing invoices, customers, products, and billing using Oracle SQL and PL/SQL. This project is designed to demonstrate key concepts in database design, procedural programming, triggers, and business logic for real-world billing workflows.
Features
Manage customers and products

Create invoices and add invoice items

Automatic stock validation and update

Calculate totals with tax (18%) and conditional discounts (5% for orders above ₹5000)

Prevent overselling with database triggers

Generate invoice summaries
sql
  ├── create_tables.sql
  ├── insert_sample_data.sql
  ├── procedures.sql
  ├── functions.sql
  ├── triggers.sql
  └── test_queries.sql
