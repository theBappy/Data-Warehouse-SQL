-- ==============================================================
-- SILVER LAYER ETL: erp_px_cat_g1v2
-- Script Version: 1.0
-- ==============================================================
PRINT '--------------------------------------------------'
PRINT 'Starting ETL for silver.erp_px_cat_g1v2...'
PRINT '--------------------------------------------------'

TRUNCATE TABLE silver.erp_px_cat_g1v2;
PRINT 'Table silver.erp_px_cat_g1v2 truncated successfully.'

INSERT INTO silver.erp_px_cat_g1v2(
    id,
    category,
    subcategory,
    maintenance
)
SELECT
    id,
    category,
    subcategory,
    maintenance
FROM bronze.erp_px_cat_g1v2
WHERE id IS NOT NULL;

PRINT 'Data inserted into silver.erp_px_cat_g1v2 successfully.'
PRINT '--------------------------------------------------'
PRINT 'ETL Completed for silver.erp_px_cat_g1v2.'
PRINT '--------------------------------------------------'
