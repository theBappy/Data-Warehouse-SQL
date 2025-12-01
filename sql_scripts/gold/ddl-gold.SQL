/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key, -- Surrogate key
    ci.customer_id                          AS customer_id,
    ci.customer_key                         AS customer_number,
    ci.customer_firstname                   AS first_name,
    ci.customer_lastname                    AS last_name,
    la.cntry                           AS country,
    ci.customer_marital_status              AS marital_status,
    CASE 
        WHEN ci.customer_gndr != 'n/a' THEN ci.customer_gndr -- CRM is the primary source for gender
        ELSE COALESCE(ca.gen, 'n/a')  			   -- Fallback to ERP data
    END                                AS gender,
    ca.bdate                           AS birthdate,
    ci.customer_create_date                 AS create_date
FROM silver.crm_customer_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.customer_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.customer_key = la.cid;
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.product_start_date, pn.product_key) AS product_key, -- Surrogate key
    pn.product_id,
    pn.product_key      AS product_number,
    pn.product_nm       AS product_name,
    pn.category_id       AS category_id,
    pc.category          AS category,
    pc.subcategory       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.product_cost     AS cost,
    pn.product_line     AS product_line,
    pn.product_start_date AS start_date
FROM silver.crm_product_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.category_id = pc.id
WHERE pn.product_end_date IS NULL; -- Filter out all historical data
GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sales_order_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sales_order_date AS order_date,
    sd.sales_ship_date  AS shipping_date,
    sd.sales_due_date   AS due_date,
    sd.sales_sls    AS sales_amount,
    sd.sales_quantity AS quantity,
    sd.sales_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sales_product_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sales_customer_id = cu.customer_id;
GO
