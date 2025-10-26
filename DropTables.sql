IF OBJECT_ID('abc_dwh.FactInventorySnapshot','U') IS NOT NULL
    DROP TABLE abc_dwh.FactInventorySnapshot;
GO
IF OBJECT_ID('abc_dwh.FactPurchaseOrder','U') IS NOT NULL
    DROP TABLE abc_dwh.FactPurchaseOrder;
GO
IF OBJECT_ID('abc_dwh.FactReceipt','U') IS NOT NULL
    DROP TABLE abc_dwh.FactReceipt;
GO
IF OBJECT_ID('abc_dwh.DimDate','U') IS NOT NULL
    DROP TABLE abc_dwh.DimDate;
GO
IF OBJECT_ID('abc_dwh.DimProduct','U') IS NOT NULL
    DROP TABLE abc_dwh.DimProduct;
GO
IF OBJECT_ID('abc_dwh.DimBrand','U') IS NOT NULL
    DROP TABLE abc_dwh.DimBrand;
GO
IF OBJECT_ID('abc_dwh.DimProductType','U') IS NOT NULL
    DROP TABLE abc_dwh.DimProductType;
GO
IF OBJECT_ID('abc_dwh.DimOutlet','U') IS NOT NULL
    DROP TABLE abc_dwh.DimOutlet;
GO
IF OBJECT_ID('abc_dwh.DimSupplier','U') IS NOT NULL
    DROP TABLE abc_dwh.DimSupplier;
GO

