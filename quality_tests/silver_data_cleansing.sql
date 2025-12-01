/*
===============================================================================
Silver Layer – Data Quality Checks
===============================================================================
Purpose:
    Validate and ensure the quality, consistency, and reliability 
    of data stored in the Silver schema.

Checks include:
    - Primary key validation (nulls, duplicates)
    - Whitespace issues
    - Data standardization and domain consistency
    - Invalid or illogical date ranges
    - Business rule validations
    - Cross-field logical consistency

Usage:
    Run this script after data loading into the Silver layer.
    Any returned rows indicate data issues requiring investigation.
===============================================================================
*/

--------------------------------------------------------------------------------
-- 1. SILVER.CRM_CUST_INFO – Customer Information Validation
--------------------------------------------------------------------------------

-- 1.1 Check for NULL or Duplicate Primary Keys
-- Expectation: No rows
SELECT 
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- 1.2 Check for Unwanted Spaces in Key Fields
-- Expectation: No rows
SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key <> TRIM(cst_key);


-- 1.3 Domain Values: Marital Status
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;


--------------------------------------------------------------------------------
-- 2. SILVER.CRM_PRD_INFO – Product Information Validation
--------------------------------------------------------------------------------

-- 2.1 Check for NULL or Duplicate Primary Keys
-- Expectation: No rows
SELECT 
    prd_id,
    COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- 2.2 Check for Unwanted Spaces
-- Expectation: No rows
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);


-- 2.3 Invalid or NULL Product Cost
-- Expectation: No rows
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 
   OR prd_cost IS NULL;


-- 2.4 Data Standardization: Product Line Values
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;


-- 2.5 Invalid Date Ranges (Start date > End date)
-- Expectation: No rows
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


--------------------------------------------------------------------------------
-- 3. SILVER.CRM_SALES_DETAILS – Sales Validation
--------------------------------------------------------------------------------

-- 3.1 Sales Date Validity Check (Raw Bronze check)
-- Valid format: YYYYMMDD between 1900 and 2050
SELECT NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
    OR LEN(sls_due_dt) != 8
    OR sls_due_dt > 20500101
    OR sls_due_dt < 19000101;


-- 3.2 Invalid Date Orders: Order > Ship or Order > Due
-- Expectation: No rows
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- 3.3 Business Rule Validation: Sales = Quantity × Price
-- Expectation: No rows
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


--------------------------------------------------------------------------------
-- 4. SILVER.ERP_CUST_AZ12 – ERP Customer Profile Validation
--------------------------------------------------------------------------------

-- 4.1 Check for Out-of-Range Birthdates
-- Expectation: Birthdates between 1924-01-01 and today
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


-- 4.2 Domain Values: Gender
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


--------------------------------------------------------------------------------
-- 5. SILVER.ERP_LOC_A101 – Location Information Validation
--------------------------------------------------------------------------------

-- 5.1 Domain Values: Country
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


--------------------------------------------------------------------------------
-- 6. SILVER.ERP_PX_CAT_G1V2 – Product Category Validation
--------------------------------------------------------------------------------

-- 6.1 Unwanted Spaces in Text Fields
-- Expectation: No rows
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);


-- 6.2 Domain Values: Maintenance Category
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;
GO
