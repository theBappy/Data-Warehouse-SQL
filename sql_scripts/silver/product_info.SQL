-- ==============================================================
-- SILVER LAYER ETL: crm_product_info
-- Script Version: 1.0
-- ==============================================================
PRINT '--------------------------------------------------'
PRINT 'Starting ETL for silver.crm_product_info...'
PRINT '--------------------------------------------------'

TRUNCATE TABLE silver.crm_product_info;
PRINT 'Table silver.crm_product_info truncated successfully.'

INSERT INTO silver.crm_product_info (
    product_id,
    category_id,
    product_key,
    product_name,
    product_cost,
    product_line,
    product_start_date,
    product_end_date
)
SELECT
    product_id,
    REPLACE(SUBSTRING(product_key, 1, 5), '-', '_') AS category_id,
    SUBSTRING(product_key, 7, LEN(product_key)) AS product_key,
    product_name,
    ISNULL(product_cost, 0) AS product_cost,
    CASE UPPER(TRIM(product_line))
         WHEN 'M' THEN 'Mountain'
         WHEN 'R' THEN 'Road'
         WHEN 'S' THEN 'Other Sales'
         WHEN 'T' THEN 'Touring'
         ELSE 'n/a'
    END AS product_line,
    CAST(product_start_date AS DATE) AS product_start_date,
    CAST(LEAD(product_start_date) OVER(PARTITION BY product_key ORDER BY product_start_date)-1 AS DATE) AS product_end_date
FROM bronze.crm_product_info
WHERE product_id IS NOT NULL;

PRINT 'Data inserted into silver.crm_product_info successfully.'
PRINT '--------------------------------------------------'
PRINT 'ETL Completed for silver.crm_product_info.'
PRINT '--------------------------------------------------'
