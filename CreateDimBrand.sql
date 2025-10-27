-- ==========================================================
-- Dimension Table: DimBrand
-- Schema : abc_dwh
-- Purpose: Stores master data about product brands
-- ==========================================================


-- Drop existing table if needed
IF OBJECT_ID('abc_dwh.DimBrand', 'U') IS NOT NULL
    DROP TABLE abc_dwh.DimBrand;
GO

CREATE TABLE abc_dwh.DimBrand
(
    BrandKey           INT IDENTITY(1,1) PRIMARY KEY,       -- Surrogate key (PK)
    BrandName          NVARCHAR(100)    NOT NULL,            -- e.g. 'Sony', 'Toshiba', 'Samsung'
    BrandDescription   NVARCHAR(255)    NULL,                -- Optional: long description
    CountryOfOrigin    NVARCHAR(100)    NULL,                -- Optional: where brand is headquartered
    IsActive           BIT             NOT NULL DEFAULT 1,  -- Flag to track active/inactive status
    CreatedDate        DATETIME        NOT NULL DEFAULT GETDATE(),  -- ETL insertion timestamp
    UpdatedDate        DATETIME        NULL,                 -- Optional: track last update
    MsgKey             UNIQUEIDENTIFIER NULL,
	ExportFlag         INT             NULL
);
GO

-- Add a unique constraint to avoid duplicate brand names
ALTER TABLE abc_dwh.DimBrand
ADD CONSTRAINT UQ_DimBrand_BrandName UNIQUE (BrandName);
GO
