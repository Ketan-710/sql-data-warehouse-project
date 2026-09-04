/*=============================================================================
    Procedure: silver.load_silver
    Purpose:   Load and transform data from the Bronze layer into the Silver
               layer with data cleansing, standardization, and validation.
=============================================================================*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY 
		SET @batch_start_time = GETDATE();
		PRINT '***************************************************************************************';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '***************************************************************************************';

		PRINT '---------------------------------------------------------------------------------------';
		PRINT 'LOADING CRM LAYER';
		PRINT '---------------------------------------------------------------------------------------';


		-- Load customer data: remove duplicates and standardize text attributes
		SET @start_time = GETDATE();
		PRINT 'Truncating table : silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		INSERT INTO silver.crm_cust_info(
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
		CASE UPPER(TRIM(cst_marital_status)) 
			WHEN 'S' THEN 'Single'
			WHEN 'M' THEN 'Married'
			ELSE 'n/a'
		END AS cst_marital_status,
		CASE UPPER(TRIM(cst_gndr)) 
			WHEN 'M' THEN 'Male'
			WHEN 'F' THEN 'Female'
			ELSE 'n/a'
		END AS cst_gndr,
		cst_create_date
		FROM (
			SELECT 
			*,
			-- Retain the most recent record for each customer
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL 
		)t
		WHERE flag = 1;
		SET @end_time = GETDATE();
		PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------'; 


		-- Load product data and derive category and product validity dates
		SET @start_time = GETDATE();
		PRINT 'Truncating table : silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		INSERT INTO silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
		SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
		prd_nm,
		COALESCE(prd_cost,'0') prd_cost,
		CASE TRIM(UPPER(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line,
		prd_start_dt  AS prd_start_dt,
		-- Set the end date to one day before the next product version starts
		LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1  AS prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------'; 


		-- Load sales data and standardize dates and financial values
		SET @start_time = GETDATE();
		PRINT 'Truncating table : silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
		SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		-- Convert invalid or improperly formatted dates to NULL
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		-- Recalculate sales when the source value is missing or inconsistent
		CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		-- Derive price when the source price is missing or invalid
		CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales/NULLIF(sls_quantity,0)
			ELSE sls_price
		END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------'; 


		-- Load ERP customer data and standardize customer ID, birth date, and gender
		SET @start_time = GETDATE();
		PRINT 'Truncating table : silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
		SELECT
		-- Remove the NAS prefix from customer IDs
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) 
			ELSE cid
		END AS cid,
		-- Replace future birth dates with NULL
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END AS bdate,
		-- Standardize gender values
		CASE WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
			WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
			ELSE 'n/a'
		END AS gen
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------'; 


		-- Load ERP location data and standardize customer IDs and country names
		SET @start_time = GETDATE();
		PRINT 'Truncating table : silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		INSERT INTO silver.erp_loc_a101(cid,cntry)
		SELECT 
		REPLACE(cid,'-','') AS cid,
		CASE WHEN UPPER(TRIM(cntry)) IN ('DE','GERMANY') THEN 'Germany'
			WHEN UPPER(TRIM(cntry)) IN ('USA','US') THEN 'United State'
			WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END AS cntry
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------'; 


		-- Load ERP product category data into the Silver layer
		SET @start_time = GETDATE();
		PRINT 'Truncating table : silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		INSERT INTO silver.erp_px_cat_g1v2(id,cat,subcat,maintance)
		SELECT 
		id,
		cat,
		subcat,
		maintance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------'; 

		SET @batch_end_time = GETDATE();
		PRINT '=================================================';
		PRINT 'Loading Bronze Layer Is Completed'
		PRINT 'Load Duration : ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=================================================';


	END TRY
	BEGIN CATCH 
		PRINT '=================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=================================================';
	END CATCH

END



	END CATCH

END
```
