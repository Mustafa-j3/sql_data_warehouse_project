/*
===========================================================
Quality Checks
=============================================================
Script Purpose:
    This script perform various quality checks for data cleasing,
transforming, consistancy, accuracy and standariztion across
silver schema. Includes checks for:
      -Null or duplicate primary key
      - Unwanted and extra spaces
      -Invalid data ranges and orders
      -Data consistancy between related tables
Note:
  cheks after load data to silver layer.
  Resolve and load any discrempancies found during checs
========================================================================
*/

-- Data Cleansing FROM BRONZE TABLES
--Duplicates from in Primary key
SELECT cst_id, count(*)
FROM silver.crm_cust_info				--cleaned for silver.crm_cust_info
Group by cst_id
Having count(*) > 1 

--==========================
--shows xtra spaces character column
select gen
from bronze.erp_cust_az12
where gen != TRIM(gen)

---------TRIM unwanted spaces----------
select prd_nm
from bronze.crm_prd_info
where prd_nm != TRIM(prd_nm)

--==========NULL OR Negative values==============
select prd_cost
from bronze.crm_prd_info
where prd_cost <0 or prd_cost is null

--standarisation and consistency
select distinct prd_line				--Distinct (UNIGQUE GENDER)		--not stander name for male M and female F
from silver.crm_prd_info

--Check for invalid data order
select * 
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

--QUALITY OF DATE COLUMS(2010920) also its integer we must convert it to date too
select 
NULLIF(sls_order_dt,0) sls_order_dt		--Zero to NULL Conversion
from bronze.crm_sales_details
where sls_order_dt < 0					--Nagetive value
OR len(sls_order_dt) != 8				--Miss information connnot change to DATE(so fix this in query)
OR sls_order_dt > 20500101				
OR sls_order_dt < 19001005	

--Invalid checks for Order date
select 
*
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt


--CHECK for Sales, Quantity and price
--BUSINESS Rules 
	-->> Sales = Quantity * price
	-->> Values must Negative , Zero and Null

select distinct
	sls_sales as old_sls_sales,
	sls_quantity,
	sls_price as old_sls_price,

case when sls_sales is null OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
		then sls_quantity * ABS(sls_price)
	else sls_sales
end AS sls_sales,
 
CASE WHEN sls_price is Null OR sls_price <=0
		then sls_sales / nullif(sls_quantity,0)
	else sls_price
end as sls_price
from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_quantity is NULL OR sls_sales is NULL OR sls_price is null
or sls_quantity <= 0 or sls_sales <=0 or sls_price <= 0
--Bad data Columns
--If sale is zero, negative and null, derive it from quantity and price
--if price is zero or null, calculate using sales and quantity
--if price is negative, convert it to zero.

select distinct
	sls_sales ,
	sls_quantity,
	sls_price 
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_quantity is NULL OR sls_sales is NULL OR sls_price is null
or sls_quantity <= 0 or sls_sales <=0 or sls_price <= 0

--=================================================
--Checking Data OUT_OF_RANGE
--Very Old bdate or Future bdate
select bdate
from silver.erp_cust_az12
where bdate> GETDATE();  -- future bdate checks
--Cleaned with NULL
--CASE WHEN bdate > GETDATE() THEN NULL
	--ELSE bdate
--END AS bdate,

--==========NULL OR Negative values==============
select gen
from bronze.erp_cust_az12
where gen <0 or gen is null
--Msg 245, Level 16, State 1, Line 96
--Conversion failed when converting the nvarchar value 'Male' to data type int.
--==============================================================
--standarisation and consistency
select distinct gen				--Distinct (UNIGQUE GENDER)		--not stander name for male M and female F

from silver.erp_cust_az12
--output: NULL,F,' ',MALE,FEMALE,M
--Transform it with following
/*
CASE WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
	 ELSE 'n/a'
end AS gen */
--==============================================================
select * from silver.erp_cust_az12
--========================================================
--Remove and replace extra information from column during matching two tables
select 	
REPLACE(id,'-','') id,
	cntry
from bronze.erp_loc_a101;
--=============================
select distinct cntry    --Distinct (UNIGQUE GENDER)		--not stander name for male M and female F
from bronze.erp_loc_a101

--check for correction
select distinct cntry as old_cntry,    --Distinct (UNIGQUE GENDER)		--not stander name for male M and female F
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 when TRIM(cntry) IN ('US','USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
	 ELSE TRIM(cntry)
end as cntry
from bronze.erp_loc_a101

select * from bronze.erp_loc_a101
