USE [ABCDWH]
GO

/****** Object:  StoredProcedure [dbo].[sp_ExportFiles]    Script Date: 10/27/2025 5:55:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE OR ALTER       PROCEDURE [dbo].[sp_ExportFiles]  
@servername Varchar(100) 
,@foldername Varchar(500)
,@databasename Varchar(50)


AS

BEGIN


Declare @Comando nVarchar(4000)
Declare @Rowsread int
Declare @DateTime as datetime
Declare @Dthbatch varchar(12)

set @DateTime = convert(datetime,Getdate(),126)
--set @Dthbatch = REPLACE(CAST(@DateTime AS DATE),'-','')+LEFT(REPLACE(CONVERT(time,@DateTime,108),':',''),4)
set @Dthbatch = ''



SET @servername = N'DESKTOP-OOETEMG'
SET @foldername = N'D:\VM\Shared\CS7079NU_A1'
SET @databasename = N'ABCDWH' 

/* Control Load Table*/
BEGIN TRY

    if exists(select 1 from sys.tables where name ='tmp_Control_Load')
	drop table dbo.tmp_Control_Load


    SELECT getdate() as DT_Execution	     
         , CAST( 'Begin MessageLOG        ' AS NVARCHAR(256)) AS DS_ProcessStep
		 , 0 as WriteRows
		  INTO dbo.tmp_Control_Load

/* End Control Load Table*/




/* Table: MESSAGELOG */

    if exists(select 1 from sys.tables where name ='tmp_MessageLog')
	drop table dbo.tmp_MessageLog
	
	SELECT MSG.[SERIALKEY],
		   MSG.[MSGKEY],
           MSG.[MSGNAME],
           MSG.[MSGDATE],
		   MSG.[MSGSTATUS],
	       MSG.[ADDDATE]
	  INTO dbo.tmp_MessageLog
      FROM [dbo].MESSAGELOG MSG
--     WHERE MSGDATE>=GETDATE()-@dateread
	 WHERE MSG.MsgDataInsert>=GETDATE()-1
  
	set @Rowsread = @@ROWCOUNT

    set @Comando = 'BCP ' + @databasename + '.dbo.tmp_Messagelog OUT ' + @foldername + '"\MessageLog' + @Dthbatch + '.csv"  -c -t\^| -T -S '+ @@servername

    exec master..xp_cmdshell @Comando

	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'End MessageLOG        ' as DS_ProcessStep
		 , @Rowsread as WriteRows
		  

	
/* Table: DimDate */

	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'Begin DimDate        ' as DS_ProcessStep
		 , 0 as WriteRows

    if exists(select 1 from sys.tables where name ='tmp_DimDate')
	drop table dbo.tmp_DimDate
	
	SELECT [DateKey]
      ,[FullDate]
      ,[DayOfWeek]
      ,[DayName]
      ,[DayOfMonth]
      ,[DayOfYear]
      ,[WeekNumber]
      ,[MonthOfYear]
      ,[MonthName]
      ,[CalendarQuarter]
      ,[CalendarYear]
      ,[IsWeekend]
      ,[FiscalMonth]
      ,[FiscalQuarter]
      ,[FiscalYear]
      ,[CreatedDate]
      ,[MsgKey]
      ,[ExportFlag]
 INTO dbo.tmp_DimDate
  FROM [abc_dwh].[DimDate]

 	 set @Rowsread = @@ROWCOUNT

     set @Comando = 'BCP ' + @databasename+ '.dbo.tmp_DimDate OUT ' + @foldername + '"\DimDate' + @Dthbatch + '.csv"  -c -t\^| -T  -S'+ @@servername
	 
	 exec master..xp_cmdshell @Comando
	
 	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'End DimDate        ' as DS_ProcessStep
		 , @Rowsread as WriteRows


/* Table: DimSupplier */

	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'Begin DimSupplier        ' as DS_ProcessStep
		 , 0 as WriteRows

    if exists(select 1 from sys.tables where name ='tmp_DimSupplier')
	drop table dbo.tmp_DimSupplier
	
SELECT [SupplierKey]
      ,[SupplierName]
      ,[Description]
      ,[Phone]
      ,[Email]
      ,[Fax]
      ,[FirstLineAddress]
      ,[PostCode]
      ,[City]
      ,[State]
      ,[CountryID]
      ,[IsActive]
      ,[CreatedDate]
      ,[UpdatedDate]
      ,[MsgKey]
      ,[ExportFlag]
INTO dbo.tmp_DimSupplier
  FROM [abc_dwh].[DimSupplier]

 	 set @Rowsread = @@ROWCOUNT

     set @Comando = 'BCP ' + @databasename+ '.dbo.tmp_DimSupplier OUT ' + @foldername + '"\DimSupplier' + @Dthbatch + '.csv"  -c -t\^| -T  -S'+ @@servername
	 
	 exec master..xp_cmdshell @Comando
	
 	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'End DimSupplier        ' as DS_ProcessStep
		 , @Rowsread as WriteRows


/* Table: DimOutlet */

	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'Begin DimOutlet        ' as DS_ProcessStep
		 , 0 as WriteRows

    if exists(select 1 from sys.tables where name ='tmp_DimOutlet')
	drop table dbo.tmp_DimOutlet
	
SELECT [OutletKey]
      ,[OutletCode]
      ,[OutletName]
      ,[OutletType]
      ,[AddressLine1]
      ,[AddressLine2]
      ,[City]
      ,[StateProvince]
      ,[PostCode]
      ,[Country]
      ,[Phone]
      ,[Email]
      ,[ManagerName]
      ,[IsActive]
      ,[CreatedDate]
      ,[UpdatedDate]
      ,[MsgKey]
      ,[ExportFlag]
INTO dbo.tmp_DimOutlet
  FROM [abc_dwh].[DimOutlet]

 	 set @Rowsread = @@ROWCOUNT

     set @Comando = 'BCP ' + @databasename+ '.dbo.tmp_DimOutlet OUT ' + @foldername + '"\DimOutlet' + @Dthbatch + '.csv"  -c -t\^| -T  -S'+ @@servername
	 
	 exec master..xp_cmdshell @Comando
	
 	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'End DimOutlet        ' as DS_ProcessStep
		 , @Rowsread as WriteRows


/* Table: DimBrand */

	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'Begin DimBrand        ' as DS_ProcessStep
		 , 0 as WriteRows

    if exists(select 1 from sys.tables where name ='tmp_DimBrand')
	drop table dbo.tmp_DimBrand
	
SELECT [BrandKey]
      ,[BrandName]
      ,[BrandDescription]
      ,[CountryOfOrigin]
      ,[IsActive]
      ,[CreatedDate]
      ,[UpdatedDate]
      ,[MsgKey]
      ,[ExportFlag]
INTO dbo.tmp_DimBrand
  FROM [abc_dwh].[DimBrand]

 	 set @Rowsread = @@ROWCOUNT

     set @Comando = 'BCP ' + @databasename+ '.dbo.tmp_DimBrand OUT ' + @foldername + '"\DimBrand' + @Dthbatch + '.csv"  -c -t\^| -T  -S'+ @@servername
	 
	 exec master..xp_cmdshell @Comando
	
 	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'End DimBrand        ' as DS_ProcessStep
		 , @Rowsread as WriteRows

/* Table: DimProductType */

	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'Begin DimProductType        ' as DS_ProcessStep
		 , 0 as WriteRows

    if exists(select 1 from sys.tables where name ='tmp_DimProductType')
	drop table dbo.tmp_DimProductType
	
SELECT [ProductTypeKey]
      ,[ProductTypeName]
      ,[ProductTypeDesc]
      ,[CategoryGroup]
      ,[IsActive]
      ,[CreatedDate]
      ,[UpdatedDate]
      ,[MsgKey]
      ,[ExportFlag]
INTO dbo.tmp_DimProductType
  FROM [abc_dwh].[DimProductType]

 	 set @Rowsread = @@ROWCOUNT

     set @Comando = 'BCP ' + @databasename+ '.dbo.tmp_DimProductType OUT ' + @foldername + '"\DimProductType' + @Dthbatch + '.csv"  -c -t\^| -T  -S'+ @@servername
	 
	 exec master..xp_cmdshell @Comando
	
 	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'End DimProductType        ' as DS_ProcessStep
		 , @Rowsread as WriteRows

/* Table: DimProduct */

	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'Begin DimProduct        ' as DS_ProcessStep
		 , 0 as WriteRows

    if exists(select 1 from sys.tables where name ='tmp_DimProduct')
	drop table dbo.tmp_DimProduct
	
SELECT [ProductKey]
      ,[ProductSKU]
      ,[ProductName]
      ,[Description]
      ,[Condition]
      ,[ProductTypeKey]
      ,[BrandKey]
      ,[SupplierKey]
      ,[Tags]
      ,[CostPrice]
      ,[RetailPrice]
      ,[CurrentStockLevel]
      ,[DateCreatedAt]
      ,[DateDiscontinuedAt]
      ,[IsActive]
      ,[CreatedDate]
      ,[UpdatedDate]
      ,[MsgKey]
      ,[ExportFlag]
INTO dbo.tmp_DimProduct
  FROM [abc_dwh].[DimProduct]

 	 set @Rowsread = @@ROWCOUNT

     set @Comando = 'BCP ' + @databasename+ '.dbo.tmp_DimProduct OUT ' + @foldername + '"\DimProduct' + @Dthbatch + '.csv"  -c -t\^| -T  -S'+ @@servername
	 
	 exec master..xp_cmdshell @Comando
	
 	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'End DimProduct        ' as DS_ProcessStep
		 , @Rowsread as WriteRows


/* Table: FactPurchaseOrder */

	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'Begin FactPurchaseOrder        ' as DS_ProcessStep
		 , 0 as WriteRows

    if exists(select 1 from sys.tables where name ='tmp_FactPurchaseOrder')
	drop table dbo.tmp_FactPurchaseOrder
	
SELECT [FactPOKey]
      ,[OrderDateKey]
      ,[ExpectedDateKey]
      ,[SupplierKey]
      ,[ProductKey]
      ,[OutletKey]
      ,[PONumber]
      ,[POLineNumber]
      ,[OrderQty]
      ,[ReceivedQty]
      ,[CancelledQty]
      ,[UnitCost]
      ,[ExtendedCost]
      ,[CurrencyCode]
      ,[UOM]
      ,[CreatedDate]
      ,[MsgKey]
      ,[ExportFlag]
INTO dbo.tmp_FactPurchaseOrder
  FROM [abc_dwh].[FactPurchaseOrder]

 	 set @Rowsread = @@ROWCOUNT

     set @Comando = 'BCP ' + @databasename+ '.dbo.tmp_FactPurchaseOrder OUT ' + @foldername + '"\FactPurchaseOrder' + @Dthbatch + '.csv"  -c -t\^| -T  -S'+ @@servername
	 
	 exec master..xp_cmdshell @Comando
	
 	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'End FactPurchaseOrder        ' as DS_ProcessStep
		 , @Rowsread as WriteRows

/* Table: FactReceipt */

	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'Begin FactReceipt        ' as DS_ProcessStep
		 , 0 as WriteRows

    if exists(select 1 from sys.tables where name ='tmp_FactReceipt')
	drop table dbo.tmp_FactReceipt
	
SELECT [FactReceiptKey]
      ,[ReceiptDateKey]
      ,[SupplierKey]
      ,[ProductKey]
      ,[OutletKey]
      ,[ReceiptNumber]
      ,[PONumber]
      ,[POLineNumber]
      ,[ReceivedQty]
      ,[RejectedQty]
      ,[UnitCost]
      ,[ExtendedCost]
      ,[BatchLot]
      ,[UOM]
      ,[CreatedDate]
      ,[MsgKey]
      ,[ExportFlag]
INTO dbo.tmp_FactReceipt
  FROM [abc_dwh].[FactReceipt]

 	 set @Rowsread = @@ROWCOUNT

     set @Comando = 'BCP ' + @databasename+ '.dbo.tmp_FactReceipt OUT ' + @foldername + '"\FactReceipt' + @Dthbatch + '.csv"  -c -t\^| -T  -S'+ @@servername
	 
	 exec master..xp_cmdshell @Comando
	
 	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'End FactReceipt        ' as DS_ProcessStep
		 , @Rowsread as WriteRows

/* Table: FactInventorySnapshot */

	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'Begin FactInventorySnapshot        ' as DS_ProcessStep
		 , 0 as WriteRows

    if exists(select 1 from sys.tables where name ='tmp_FactInventorySnapshot')
	drop table dbo.tmp_FactInventorySnapshot
	
SELECT [FactInvSnapKey]
      ,[SnapshotDateKey]
      ,[ProductKey]
      ,[OutletKey]
      ,[QtyOnHand]
      ,[QtyAllocated]
      ,[QtyOnOrder]
      ,[AvgUnitCost]
      ,[InventoryValue]
      ,[CreatedDate]
      ,[MsgKey]
      ,[ExportFlag]
INTO dbo.tmp_FactInventorySnapshot
  FROM [abc_dwh].[FactInventorySnapshot]

 	 set @Rowsread = @@ROWCOUNT

     set @Comando = 'BCP ' + @databasename+ '.dbo.tmp_FactInventorySnapshot OUT ' + @foldername + '"\FactInventorySnapshot' + @Dthbatch + '.csv"  -c -t\^| -T  -S'+ @@servername
	 
	 exec master..xp_cmdshell @Comando
	
 	INSERT INTO dbo.tmp_Control_Load
    SELECT getdate() as DT_Execution
	     , 'End FactInventorySnapshot        ' as DS_ProcessStep
		 , @Rowsread as WriteRows



	
	END TRY
BEGIN CATCH


 if exists(select 1 from sys.tables where name ='tmp_Control_Load_ERROR')
	drop table dbo.[tmp_Control_Load_ERROR]


  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    CAST(ERROR_PROCEDURE() AS NVARCHAR(256)) AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage
  INTO dbo.tmp_Control_Load_ERROR
END CATCH;
END


GO


