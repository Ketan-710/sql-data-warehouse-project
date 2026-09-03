
/*
================================================================================
Script: Initialize Data Warehouse Database

Drops the existing DataWarehouse database (if present), creates
             a new database, and creates Bronze, Silver, and Gold schemas.
================================================================================
*/

-- Switch to the master database to manage database-level operations
USE master;
GO

-- Drop the existing DataWarehouse database if it already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWareHouse')
BEGIN
	DROP DATABASE DataWareHouse;
END;
GO

-- Create a DataWarehouse database
CREATE DATABASE DataWareHouse;
GO

-- Switch to the newly created DataWarehouse database
USE DataWarehouse;
GO

-- Create schemas 
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

