-- ==========================================================
-- Dimension Table: DimProduct
-- Schema : abc_dwh
-- Purpose: Stores product master data and links to Brand, ProductType, and Supplier
-- ==========================================================

-- Drop existing table if needed
IF OBJECT_ID('abc_dwh.DimProduct', 'U') IS NOT NULL
    DROP TABLE abc_dwh.DimProduct;
GO

CREATE TABLE abc_dwh.DimProduct
(
    ProductKey         INT IDENTITY(1,1) PRIMARY KEY,        -- Surrogate key for DWH joins
    ProductSKU         NVARCHAR(50)     NOT NULL,             -- Natural business key from source (e.g., 'SO6677')
    ProductName        NVARCHAR(255)    NOT NULL,             -- e.g., 'Manfrotto MT057C3 Carbon Fibre Tripod'
    [Description]      NVARCHAR(255)    NULL,
    [Condition]        NVARCHAR(50)     NULL,                 -- e.g., 'New', 'Display', 'Refurbished'

    -- Foreign Keys to other dimensions
    ProductTypeKey     INT             NOT NULL,             -- FK → DimProductType
    BrandKey           INT             NOT NULL,             -- FK → DimBrand
    SupplierKey        INT             NULL,                 -- FK → DimSupplier (optional, some data may be null)

    Tags               NVARCHAR(255)    NULL,                 -- e.g., 'FILTERS, TRIPODS'
    CostPrice          DECIMAL(18,2)   NULL,
    RetailPrice        DECIMAL(18,2)   NULL,
    CurrentStockLevel  INT             NULL,

    DateCreatedAt      DATE            NULL,                 -- Original creation date from source
    DateDiscontinuedAt DATE            NULL,
    IsActive           BIT             NOT NULL DEFAULT 1,   -- 1=Active, 0=Inactive

    CreatedDate        DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedDate        DATETIME        NULL,
    MsgKey             UNIQUEIDENTIFIER NULL,
	ExportFlag         INT             NULL
);
GO

-- ==========================================================
-- Add uniqueness and helpful indexes
-- ==========================================================
ALTER TABLE abc_dwh.DimProduct
ADD CONSTRAINT UQ_DimProduct_SKU UNIQUE (ProductSKU);



-- ==========================================================
-- Add foreign key relationships
-- ==========================================================
ALTER TABLE abc_dwh.DimProduct
ADD CONSTRAINT FK_DimProduct_ProductType
    FOREIGN KEY (ProductTypeKey) REFERENCES abc_dwh.DimProductType(ProductTypeKey);

ALTER TABLE abc_dwh.DimProduct
ADD CONSTRAINT FK_DimProduct_Brand
    FOREIGN KEY (BrandKey) REFERENCES abc_dwh.DimBrand(BrandKey);

ALTER TABLE abc_dwh.DimProduct
ADD CONSTRAINT FK_DimProduct_Supplier
    FOREIGN KEY (SupplierKey) REFERENCES abc_dwh.DimSupplier(SupplierKey);
GO


