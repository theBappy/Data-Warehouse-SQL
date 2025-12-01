-- ==============================================================
-- SILVER LAYER ETL: erp_location_a101
-- Script Version: 1.0
-- ==============================================================
PRINT '--------------------------------------------------'
PRINT 'Starting ETL for silver.erp_location_a101...'
PRINT '--------------------------------------------------'

TRUNCATE TABLE silver.erp_location_a101;
PRINT 'Table silver.erp_location_a101 truncated successfully.'

INSERT INTO silver.erp_location_a101 (
    cid, 
    cntry
)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE 
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_location_a101
WHERE cid IS NOT NULL;

PRINT 'Data inserted into silver.erp_location_a101 successfully.'
PRINT '--------------------------------------------------'
PRINT 'ETL Completed for silver.erp_location_a101.'
PRINT '--------------------------------------------------'
