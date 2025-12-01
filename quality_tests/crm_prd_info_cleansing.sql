/*
===============================================================================
Bronze Layer – Product Data Quality & Transformation
===============================================================================
Purpose:
    Perform data quality checks and initial transformations for the 
    'crm_prd_info' table in the Bronze layer.
Checks and transformations include:
    - Category ID extraction from product key
    - Validation against reference categories (erp_px_cat_g1v2)
    - Duplicate and null checks on product ID
    - Whitespace cleanup
    - Cost validation
    - Date consistency checks
    - Standardization of product lines
===============================================================================
*/

--------------------------------------------------------------------------------
-- 1. Extract Category ID from prd_key and validate against ERP categories
--------------------------------------------------------------------------------
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    prd_name,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (
    SELECT DISTINCT id
    FROM bronze.erp_px_cat_g1v2
);

--------------------------------------------------------------------------------
-- 2. Check for duplicate or null product IDs
-- Expectation: No rows
--------------------------------------------------------------------------------
SELECT
    prd_id,
    COUNT(*) AS record_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

--------------------------------------------------------------------------------
-- 3. Preview ERP Categories for reference
--------------------------------------------------------------------------------
SELECT DISTINCT id
FROM bronze.erp_px_cat_g1v2;

--------------------------------------------------------------------------------
-- 4. Check product keys exist in sales table
--------------------------------------------------------------------------------
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key_suffix,
    prd_name,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) IN (
    SELECT sls_prd_key
    FROM bronze.crm_sales_details
);

--------------------------------------------------------------------------------
-- 5. Check for unwanted spaces in product names
-- Expectation: No rows
--------------------------------------------------------------------------------
SELECT prd_name
FROM bronze.crm_prd_info
WHERE prd_name <> TRIM(prd_name);

--------------------------------------------------------------------------------
-- 6. Check for invalid or null product cost
-- Expectation: No rows
--------------------------------------------------------------------------------
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

--------------------------------------------------------------------------------
-- 7. Standardize product cost and product line
--------------------------------------------------------------------------------
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key_suffix,
    prd_name,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line_standardized,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;

--------------------------------------------------------------------------------
-- 8. Check for invalid date orders (prd_start_dt > prd_end_dt)
-- Expectation: No rows
--------------------------------------------------------------------------------
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

--------------------------------------------------------------------------------
-- 9. Review distinct product lines
--------------------------------------------------------------------------------
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;
GO
