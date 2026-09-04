/*
================================================================================
Data Quality Validation - Silver Layer
================================================================================
Purpose:
    Validate the Silver Layer data for common data quality issues, including
    NULL values, duplicates, unwanted spaces, invalid dates, and inconsistent
    or non-standardized values.

These checks ensure that the transformed Silver Layer data is clean,
consistent, and ready for downstream analytics and reporting.
================================================================================
*/


-- Check for NULL values and duplicate customer IDs
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL 


-- Check for unwanted leading or trailing spaces in customer first names
SELECT 
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


-- Check the standardized marital status values
SELECT DISTINCT 
cst_marital_status
FROM silver.crm_cust_info


-- Check the standardized gender values
SELECT DISTINCT 
cst_gndr
FROM silver.crm_cust_info


-- Check for duplicate product IDs
SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1


-- Check for unwanted leading or trailing spaces in product keys
SELECT
prd_key
FROM silver.crm_prd_info
WHERE prd_key != TRIM(prd_key)


-- Check for unwanted leading or trailing spaces in product names
SELECT
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


-- Check the standardized product line values
SELECT DISTINCT
prd_line
FROM silver.crm_prd_info


-- Check for invalid product date ranges
SELECT 
*
FROM silver.crm_prd_info
WHERE  prd_end_dt < prd_start_dt


-- Check for duplicate sales order numbers
SELECT 
sls_ord_num,
COUNT(*)
FROM silver.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*)>1


-- Check for invalid or incorrectly formatted order dates
SELECT 
sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 or LEN(sls_order_dt) != 8 


-- Check sales data for inconsistent, NULL, or non-positive values
SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details 
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0


-- Identify future birth dates that are considered invalid
SELECT bdate FROM silver.erp_cust_az12
WHERE bdate > GETDATE()


-- Check the standardized gender values
SELECT DISTINCT gen FROM silver.erp_cust_az12


-- Check country values for consistency and standardization
SELECT DISTINCT cntry FROM bronze.erp_loc_a101
