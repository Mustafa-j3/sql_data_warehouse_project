	/*
	check whether the table is exist or not. 
	if it exist drop it and recreate it again
	*/
	if OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
		DROP TABLE bronze.crm_cust_info;
	CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
	);
	select *
	from bronze.crm_cust_info

	if OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL
		DROP TABLE bronze.crm_prd_info;
	CREATE TABLE bronze.crm_prd_info (
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
	);


	if OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL
		DROP TABLE bronze.crm_sales_details;
	CREATE TABLE bronze.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales int,
	sls_quantity int,
	sls_price int
	);

	if OBJECT_ID ('bronze.erp_loc_a101','U') IS NOT NULL
		DROP TABLE bronze.erp_loc_a101;
	CREATE TABLE bronze.erp_loc_a101 (
		id NVARCHAR(50),
		cntry NVARCHAR(50),
	);

	if OBJECT_ID ('bronze.erp_cust_az12','U') IS NOT NULL
		DROP TABLE bronze.erp_cust_az12;
	CREATE TABLE bronze.erp_cust_az12 (
		cid		NVARCHAR(50),
		bdate	Date,
		gen		NVARCHAR(50),
	);

	if OBJECT_ID ('bronze.erp_px_cat_g1v2','U') IS NOT NULL
		DROP TABLE bronze.erp_px_cat_g1v2;
	CREATE TABLE bronze.erp_px_cat_g1v2 (
		id			NVARCHAR(50),
		cat			NVARCHAR(50),
		subcat		NVARCHAR(50),
		maintenance	NVARCHAR(50),
	);
		truncate table bronze.crm_cust_info /* used to first clear all data and then full load*/
		BULK INSERT bronze.crm_cust_info
		from 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SELECT * FROM bronze.crm_cust_info
		/*
		count the number of rows
		*/
		select count(*) from bronze.crm_cust_info
		/*========================================*/

		truncate table bronze.crm_prd_info /* used to first clear all data and then full load*/
		BULK INSERT bronze.crm_prd_info
		from 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		/*====================================*/
		truncate table bronze.crm_sales_details /* used to first clear all data and then full load*/
		BULK INSERT bronze.crm_sales_details
		from 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		/*====================================*/
		truncate table bronze.erp_cust_az12 /* used to first clear all data and then full load*/
		BULK INSERT bronze.erp_cust_az12
		from 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		with (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		/*====================================*/
		truncate table bronze.erp_loc_a101 /* used to first clear all data and then full load*/
		BULK INSERT bronze.erp_loc_a101
		from 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		/*====================================*/
		truncate table bronze.erp_px_cat_g1v2 /* used to first clear all data and then full load*/
		BULK INSERT bronze.erp_px_cat_g1v2
		from 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
