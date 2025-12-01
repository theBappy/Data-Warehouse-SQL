/*
===============================================================================
Data Quality & Cleansing Script for Bronze Layer
===============================================================================
Purpose:
    - Validate primary key uniqueness
    - Check for null PK values
    - Identify whitespace issues
    - Standardize gender & marital status
    - Deduplicate customer records selecting latest version
    - Load clean data into Silver Layer
-------------------------------------------------------------------------------
Note:
    Bronze = raw landing zone
    Silver = cleaned, standardized, analytics-ready zone
===============================================================================
*/

-------------------------------------------------------------------------------
-- 1. Check for Duplicate or NULL Primary Keys (cst_id)
-------------------------------------------------------------------------------
SELECT 
    cst_id,
    COUNT(*) AS record_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;
-- Expectation: No results
-- Action required if duplicates or null PK exist


-------------------------------------------------------------------------------
-- 2. Preview Deduplication Logic
--    (Keep latest record based on cst_create_date)
-------------------------------------------------------------------------------
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
                PARTITION BY cst_id 
                ORDER BY cst_create_date DESC
           ) AS rn
    FROM bronze.crm_cust_info
) d
WHERE rn != 1;
-- These are the duplicate records that will be removed


-------------------------------------------------------------------------------
-- 3. Inspect deduped result for a sample customer (e.g., 29466)
-------------------------------------------------------------------------------
SELECT *,
       ROW_NUMBER() OVER (
            PARTITION BY cst_id 
            ORDER BY cst_create_date DESC
       ) AS rn
FROM bronze.crm_cust_info
WHERE cst_id = 29466;

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
                PARTITION BY cst_id 
                ORDER BY cst_create_date DESC
           ) AS rn
    FROM bronze.crm_cust_info
) d
WHERE rn = 1
  AND cst_id = 29466;


-------------------------------------------------------------------------------
-- 4. Whitespace Checks (should return zero rows)
-------------------------------------------------------------------------------
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname <> TRIM(cst_lastname);

SELECT cst_gender
FROM bronze.crm_cust_info
WHERE cst_gender <> TRIM(cst_gender);


-------------------------------------------------------------------------------
-- 5. Data Standardization (Review source domain values)
-------------------------------------------------------------------------------
SELECT DISTINCT cst_gender
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;


-------------------------------------------------------------------------------
-- 6. Load Cleaned Data into Silver Layer
--    - Deduplicated (latest record)
--    - Trimmed names
--    - Standardized Gender: M/F ? Male/Female
--    - Standardized Marital Status: S/M ? Single/Married
-------------------------------------------------------------------------------
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,

    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,

    CASE 
        WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gender,

    cst_create_date
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
                PARTITION BY cst_id 
                ORDER BY cst_create_date DESC
           ) AS rn
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) d
WHERE rn = 1;
GO
