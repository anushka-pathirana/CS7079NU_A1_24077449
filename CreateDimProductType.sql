-- ==========================================================
-- Dimension Table: DimProductType
-- Schema : abc_dwh
-- Purpose: Stores master data about product types or categories
-- ==========================================================


-- Drop existing table if needed
IF OBJECT_ID('abc_dwh.DimProductType', 'U') IS NOT NULL
    DROP TABLE abc_dwh.DimProductType;
GO

CREATE TABLE abc_dwh.DimProductType
(
    ProductTypeKey     INT IDENTITY(1,1) PRIMARY KEY,       -- Surrogate key (PK)
    ProductTypeName    VARCHAR(100)    NOT NULL,            -- e.g., 'ACCESSORY', 'IMAGING', 'CAMCORDER'
    ProductTypeDesc    VARCHAR(255)    NULL,                -- Optional: longer description
    CategoryGroup      VARCHAR(100)    NULL,                -- Optional: higher-level grouping (e.g. 'Electronics')
    IsActive           BIT             NOT NULL DEFAULT 1,  -- 1 = active, 0 = inactive
    CreatedDate        DATETIME        NOT NULL DEFAULT GETDATE(),  -- ETL insertion timestamp
    UpdatedDate        DATETIME        NULL,                 -- Optional: track last update
    MsgKey             UNIQUEIDENTIFIER NULL,
	ExportFlag         INT             NULL
);
GO

-- Ensure unique product type names
ALTER TABLE abc_dwh.DimProductType
ADD CONSTRAINT UQ_DimProductType_Name UNIQUE (ProductTypeName);
GO
