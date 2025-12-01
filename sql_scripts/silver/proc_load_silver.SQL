
EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	-- ==============================================================
	-- MASTER SILVER LAYER ETL SCRIPT
	-- Version: 1.0
	-- Author: [Your Name]
	-- Run Timestamp: GETDATE() will be printed at runtime
	-- Description: Loads and cleanses all Silver tables from Bronze layer
	-- ==============================================================
	PRINT '=================================================='
	PRINT 'Starting Master Silver Layer ETL'
	PRINT 'Run Timestamp: ' + CONVERT(VARCHAR, GETDATE(), 120)
	PRINT '=================================================='

	/* ==============================================================
	   1️⃣ silver.crm_customer_info
	   ============================================================== */
	PRINT '--------------------------------------------------'
	PRINT 'Starting ETL for silver.crm_customer_info...'
	TRUNCATE TABLE silver.crm_customer_info;
	PRINT 'Table silver.crm_customer_info truncated successfully.'

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
	PRINT 'ETL Completed for silver.crm_customer_info.'
	PRINT '--------------------------------------------------'

	/* ==============================================================
	   2️⃣ silver.crm_product_info
	   ============================================================== */
	PRINT 'Starting ETL for silver.crm_product_info...'
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
	PRINT 'ETL Completed for silver.crm_product_info.'
	PRINT '--------------------------------------------------'

	/* ==============================================================
	   3️⃣ silver.crm_sales_details
	   ============================================================== */
	PRINT 'Starting ETL for silver.crm_sales_details...'
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
	PRINT 'ETL Completed for silver.crm_sales_details.'
	PRINT '--------------------------------------------------'

	/* ==============================================================
	   4️⃣ silver.erp_customer_az12
	   ============================================================== */
	PRINT 'Starting ETL for silver.erp_customer_az12...'
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
	PRINT 'ETL Completed for silver.erp_customer_az12.'
	PRINT '--------------------------------------------------'

	/* ==============================================================
	   5️⃣ silver.erp_location_a101
	   ============================================================== */
	PRINT 'Starting ETL for silver.erp_location_a101...'
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
	PRINT 'ETL Completed for silver.erp_location_a101.'
	PRINT '--------------------------------------------------'

	/* ==============================================================
	   6️⃣ silver.erp_px_cat_g1v2
	   ============================================================== */
	PRINT 'Starting ETL for silver.erp_px_cat_g1v2...'
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
	PRINT 'ETL Completed for silver.erp_px_cat_g1v2.'
	PRINT '--------------------------------------------------'

	PRINT '=================================================='
	PRINT 'MASTER SILVER LAYER ETL COMPLETED SUCCESSFULLY!'
	PRINT 'Run Timestamp: ' + CONVERT(VARCHAR, GETDATE(), 120)
	PRINT '=================================================='
END
