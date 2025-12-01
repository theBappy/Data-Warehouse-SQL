-- ==============================================================
-- SILVER LAYER ETL: crm_sales_details
-- Script Version: 1.0
-- ==============================================================
PRINT '--------------------------------------------------'
PRINT 'Starting ETL for silver.crm_sales_details...'
PRINT '--------------------------------------------------'

TRUNCATE TABLE silver.crm_sales_details;
PRINT 'Table silver.crm_sales_details truncated successfully.'

INSERT INTO silver.crm_sales_details (
    sales_order_num,
    sales_product_key,
    sales_customer_id,
    sales_order_date,
    sales_ship_date,
    sales_due_date,
    sales_sls,
    sales_quantity,
    sales_price
)
SELECT 
    sales_order_num,
    sales_product_key,
    sales_customer_id,
    CASE 
         WHEN sales_order_date = 0 OR LEN(sales_order_date) != 8 THEN NULL
         ELSE CAST(CAST(sales_order_date AS VARCHAR) AS DATE)
    END AS sales_order_date,
    CASE 
         WHEN sales_ship_date = 0 OR LEN(sales_ship_date) != 8 THEN NULL
         ELSE CAST(CAST(sales_ship_date AS VARCHAR) AS DATE)
    END AS sales_ship_date,
    CASE 
         WHEN sales_due_date = 0 OR LEN(sales_due_date) != 8 THEN NULL
         ELSE CAST(CAST(sales_due_date AS VARCHAR) AS DATE)
    END AS sales_due_date,
    CASE 
        WHEN sales_sls IS NULL OR sales_sls <= 0 OR sales_sls != sales_quantity * ABS(sales_price)
            THEN sales_quantity * ABS(sales_price)
        ELSE sales_sls
    END AS sales_sls,
    sales_quantity,
    CASE 
        WHEN sales_price IS NULL OR sales_price <= 0
            THEN sales_sls  / NULLIF(sales_quantity, 0)
        ELSE sales_price
    END AS sales_price
FROM bronze.crm_sales_details
WHERE sales_order_num IS NOT NULL;

PRINT 'Data inserted into silver.crm_sales_details successfully.'
PRINT '--------------------------------------------------'
PRINT 'ETL Completed for silver.crm_sales_details.'
PRINT '--------------------------------------------------'
