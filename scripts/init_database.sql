/*
=======================================================================
Create databse and Schemas
=======================================================================
This script create new database name 'DataWarehouse' after checking if it already exist.
if database exists it drop and recreate. Additionally, the script also create 3 schemas in 
database i.e. Bronze, Silver and golden.
==================================
Warnings:
          Running this script will all delete your entire 'DataWarehouse' which result lose of
data too. So, make sure! before running it.
          
*/



--drop and recreate the databse 'warehouse'
if exit (SELECT 1 from sys.databases where name='Datawarehouse')
begin
  ALTER database DataWarehouse SET single_user with ROLLBACK Immediate;
Drop database DataWarehouse;

end;


USE MASTER;
CREATE DATABASE DataWarehouse;

use DataWarehouse;

Go
CREATE SCHEMA bronze;
Go
CREATE SCHEMA silver;
Go
CREATE SCHEMA gold;
Go
