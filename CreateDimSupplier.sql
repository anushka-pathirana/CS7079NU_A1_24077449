-- ==========================================================
-- Dimension Table: DimSupplier
-- Schema : abc_dwh
-- Purpose: Master data for suppliers (for POs, receipts, etc.)
-- ==========================================================


-- Drop existing table if needed
IF OBJECT_ID('abc_dwh.DimSupplier', 'U') IS NOT NULL
    DROP TABLE abc_dwh.DimSupplier;
GO

CREATE TABLE abc_dwh.DimSupplier
(
    SupplierKey        INT IDENTITY(1,1) PRIMARY KEY,   -- Surrogate PK

    -- Natural/business attributes (from SampleOfSuppliers.txt)
    SupplierName       VARCHAR(150)   NOT NULL,          -- e.g., 'SONY', 'JVC', 'Samsung'
    [Description]      VARCHAR(255)   NULL,
    Phone              VARCHAR(50)    NULL,
    Email              VARCHAR(150)   NULL,
    Fax                VARCHAR(50)    NULL,
    FirstLineAddress   VARCHAR(255)   NULL,
    PostCode           VARCHAR(20)    NULL,
    City               VARCHAR(100)   NULL,
    [State]            VARCHAR(100)   NULL,
    CountryID          INT            NULL,              -- Optionally FK to a DimCountry later

    -- DW/ETL management
    IsActive           BIT            NOT NULL DEFAULT 1,
    CreatedDate        DATETIME       NOT NULL DEFAULT GETDATE(),
    UpdatedDate        DATETIME       NULL,
    MsgKey             UNIQUEIDENTIFIER NULL,
	ExportFlag         INT             NULL
);
GO

-- Ensure no duplicate supplier names
ALTER TABLE abc_dwh.DimSupplier
ADD CONSTRAINT UQ_DimSupplier_SupplierName UNIQUE (SupplierName);
GO

