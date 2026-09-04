/* =========================================================
   Load Source Data into Bronze Layer
   ========================================================= */

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME , @batch_start_time DATETIME , @batch_end_time DATETIME
		BEGIN TRY 

			-- Start overall batch timer
			SET @batch_start_time = GETDATE();
			PRINT '***************************************************************************************';
			PRINT 'LOADING BRONZE LAYER';
			PRINT '***************************************************************************************';


			-- Load CRM source tables
			PRINT '---------------------------------------------------------------------------------------';
			PRINT 'LOADING CRM LAYER';
			PRINT '---------------------------------------------------------------------------------------';


			SET @start_time = GETDATE();
			PRINT 'TRUNCATING TABLE : bronze.crm_cust_info';
			TRUNCATE TABLE bronze.crm_cust_info; -- Remove existing data

			PRINT 'INSERTING DATA INTO : bronze.crm_cust_info';
			BULK INSERT bronze.crm_cust_info
			FROM 'C:\Users\ketan\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
			SET @end_time = GETDATE();
			PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
			PRINT '---------------------------'; 


			SET @start_time = GETDATE();
			PRINT 'TRUNCATING TABLE : bronze.crm_prd_info';
			TRUNCATE TABLE bronze.crm_prd_info; -- Remove existing data

			PRINT 'INSERTING DATA INTO : bronze.crm_prd_info';
			BULK INSERT bronze.crm_prd_info
			FROM 'C:\Users\ketan\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
			SET @end_time = GETDATE();
			PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
			PRINT '---------------------------'; 


			SET @start_time = GETDATE();
			PRINT 'TRUNCATING TABLE : bronze.crm_sales_details';
			TRUNCATE TABLE bronze.crm_sales_details; -- Remove existing data

			PRINT 'INSERTING DATA INTO : bronze.crm_sales_details';
			BULK INSERT bronze.crm_sales_details
			FROM 'C:\Users\ketan\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
			SET @end_time = GETDATE();
			PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
			PRINT '---------------------------'; 


			-- Load ERP source tables
			PRINT '---------------------------------------------------------------------------------------';
			PRINT 'LOADING ERP LAYER';
			PRINT '---------------------------------------------------------------------------------------';


			SET @start_time = GETDATE();
			PRINT 'TRUNCATING TABLE : bronze.erp_cust_az12';
			TRUNCATE TABLE bronze.erp_cust_az12; -- Remove existing data

			PRINT 'INSERTING DATA INTO : bronze.erp_cust_az12';
			BULK INSERT bronze.erp_cust_az12
			FROM 'C:\Users\ketan\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
			SET @end_time = GETDATE();
			PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
			PRINT '---------------------------'; 


			SET @start_time = GETDATE();
			PRINT 'TRUNCATING TABLE : bronze.erp_loc_a101';
			TRUNCATE TABLE bronze.erp_loc_a101; -- Remove existing data

			PRINT 'INSERTING DATA INTO : bronze.erp_loc_a101';
			BULK INSERT bronze.erp_loc_a101
			FROM 'C:\Users\ketan\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
			SET @end_time = GETDATE();
			PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
			PRINT '---------------------------'; 


			SET @start_time = GETDATE();
			PRINT 'TRUNCATING TABLE : bronze.erp_px_cat_g1v2';
			TRUNCATE TABLE bronze.erp_px_cat_g1v2; -- Remove existing data

			PRINT 'INSERTING DATA INTO : bronze.erp_px_cat_g1v2';
			BULK INSERT bronze.erp_px_cat_g1v2
			FROM 'C:\Users\ketan\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
			SET @end_time = GETDATE();
			PRINT 'Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
			PRINT '---------------------------'; 

			-- End overall batch timer
			SET @batch_end_time = GETDATE();
				PRINT '=================================================';
				PRINT 'Loading Bronze Layer Is Completed'
				PRINT 'Load Duration : ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
				PRINT '=================================================';

			END TRY

			-- Handle errors during the loading process
			BEGIN CATCH
				PRINT '=================================================';
				PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
				PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
				PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
				PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
				PRINT '=================================================';
			END CATCH
END
