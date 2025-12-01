-- ==============================================================
-- SILVER LAYER ETL: crm_customer_info
-- Script Version: 1.0
-- ==============================================================
PRINT '--------------------------------------------------'
PRINT 'Starting ETL for silver.crm_customer_info...'
PRINT '--------------------------------------------------'

-- Step 1: Truncate the Silver table to load fresh data
TRUNCATE TABLE silver.crm_customer_info;
PRINT 'Table silver.crm_customer_info truncated successfully.'

-- Step 2: Insert cleansed and standardized data from Bronze
INSERT INTO silver.crm_customer_info (
    customer_id,
    customer_key,
    customer_firstname,
    customer_lastname,
    customer_marital_status,
    customer_gender,
    customer_create_date
)
SELECT 
    customer_id,
    customer_key,
    TRIM(customer_firstname) AS customer_firstname,
    TRIM(customer_lastname) AS customer_lastname,
    CASE 
        WHEN UPPER(TRIM(customer_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(customer_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS customer_marital_status,
    CASE 
        WHEN UPPER(TRIM(customer_gender)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(customer_gender)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS customer_gender,
    customer_create_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_create_date DESC) AS flag_last
    FROM bronze.crm_customer_info
    WHERE customer_id IS NOT NULL
) t
WHERE flag_last = 1;

PRINT 'Data inserted into silver.crm_customer_info successfully.'
PRINT '--------------------------------------------------'
PRINT 'ETL Completed for silver.crm_customer_info.'
PRINT '--------------------------------------------------'
