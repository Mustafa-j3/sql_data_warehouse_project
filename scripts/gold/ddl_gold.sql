/*
=================================================================
DDL Script: Create Gold View
=========================================================
Sript Purpose:
    This script create view for gold layer in DWH.
The gold layer represent the final dimension and fact table(star schema)

Each view perform transformation and combines data from silver layer
to produce clean,enrich and decision making dataset.

*/

--==============================================================
--    gold.dim_customer
--====================================================================
if object_id('gold.dim_customer','V') IS NOT NULL
		DROP VIEW gold.dim_customer;
	GO
--select cst_id, count(*) from			--checking duplicates while joining
--(
--All layers in gold is gonna be virtual one, so create view for it
CREATE VIEW gold.dim_customer AS		--dim for dimension as this not a fact table
--(check the quality of view
--select * from gold.dim_customer)
Select ROW_NUMBER() 
	   OVER(order by cst_id) as customer_key,	
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_material_status AS material_status,
CASE
	WHEN ci.cst_gndr !='n/a' Then ci.cst_gndr  --CRM is the Master of gender info
	ELSE COALESCE(ca.gen,'n/a')						--if n/a is Master table so it will get from other table
end as gender,
ca.bdate AS birth_date,
ci.cst_create_date AS create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.id

--=================================================================
--gold.dim_product
--============================================================
if object_id('gold.dim_products','V') IS NOT NULL
		DROP VIEW gold.dim_products;
	GO

CREATE VIEW gold.dim_products AS
--Check for view
--select * from gold.dim_products

--select prd_key, count(*) from (  --DUPLICATE CHECK
select 
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,		--PrimaryKey(surrogateKey Only used to connect data model
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS catagory_id,
	pc.cat AS catagory,
	pc.subcat AS sub_catagory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_line
--pn.prd_end_dt --we do not include coz is always NULL
from silver.crm_prd_info pn
lEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL	--from end date Null value is NEW record 
--)t Group by prd_key		--check duplicates
--HAVING COUNT(*)>1
--=====================================================================
--    gold.fact_sales
--===========================================================================

if object_id('gold.fact_sales','V') IS NOT NULL
		DROP VIEW gold.fact_sales;
	GO
CREATE VIEW gold.fact_sales AS
--Check view quality
--select * from gold.fact_sales
--check if all dimension tables can successfully join to the fact table
/*
select * from gold.fact_sales f
left JOIN gold.dim_customer c
ON c.customer_key = f.customer_key
--where c.customer_key is null			--for dim customer check
LEFT JOIN gold.dim_products p
on p.product_key = f.product_key
where p.product_key IS NULL			
*/
select 
sd.sls_ord_num AS order_number,
pr.product_key,   --from gold dim
--sd.sls_prd_key,	--Now we didn't need this key from sources coz we already have surrogate key from dim 
--cu.customer_key,
--sd.sls_cust_id,	--Now we didn't need this key from sources coz we already have surrogate key from dim
--The above two key will help connect Fact with dimension
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipment_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price AS price
from silver.crm_sales_details sd  
left join gold.dim_products	pr		--joining Silver dim with gold
ON sd.sls_prd_key = pr.product_number  --prd key above silver dim and product number from 
LEFT JOIN gold.dim_customer cu
on sd.sls_cust_id = cu.customer_id
