-- ==============================================================
-- SILVER LAYER ETL: erp_customer_az12
-- Script Version: 1.0
-- ==============================================================
PRINT '--------------------------------------------------'
PRINT 'Starting ETL for silver.erp_customer_az12...'
PRINT '--------------------------------------------------'

TRUNCATE TABLE silver.erp_customer_az12;
PRINT 'Table silver.erp_customer_az12 truncated successfully.'

INSERT INTO silver.erp_customer_az12(
    cid, 
    bdate, 
    gen
)
SELECT
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
         ELSE cid
    END AS cid,
    CASE WHEN bdate > GETDATE() THEN NULL
         ELSE bdate
    END AS bdate,
    CASE 
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_customer_az12
WHERE cid IS NOT NULL;

PRINT 'Data inserted into silver.erp_customer_az12 successfully.'
PRINT '--------------------------------------------------'
PRINT 'ETL Completed for silver.erp_customer_az12.'
PRINT '--------------------------------------------------'
