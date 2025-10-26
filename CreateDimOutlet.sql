-- ==========================================================
-- Dimension Table: DimOutlet
-- Schema : abc_dwh
-- Purpose: Stores information about physical or online outlets
-- ==========================================================


-- Drop existing table if needed
IF OBJECT_ID('abc_dwh.DimOutlet', 'U') IS NOT NULL
    DROP TABLE abc_dwh.DimOutlet;
GO

CREATE TABLE abc_dwh.DimOutlet
(
    OutletKey          INT IDENTITY(1,1) PRIMARY KEY,         -- Surrogate key (PK)
    OutletCode         VARCHAR(50)     NOT NULL,              -- Unique store code (e.g., 'ABC001')
    OutletName         VARCHAR(150)    NOT NULL,              -- Outlet or store name (e.g., 'ABC Warehouse')
    OutletType         VARCHAR(50)     NULL,                  -- e.g., 'Retail Store', 'Warehouse', 'Online'
    AddressLine1       VARCHAR(255)    NULL,
    AddressLine2       VARCHAR(255)    NULL,
    City               VARCHAR(100)    NULL,
    StateProvince      VARCHAR(100)    NULL,
    PostCode           VARCHAR(20)     NULL,
    Country            VARCHAR(100)    NULL,
    Phone              VARCHAR(50)     NULL,
    Email              VARCHAR(150)    NULL,
    ManagerName        VARCHAR(150)    NULL,                  -- Optional: store manager
    IsActive           BIT             NOT NULL DEFAULT 1,    -- 1=Active, 0=Inactive
    CreatedDate        DATETIME        NOT NULL DEFAULT GETDATE(),
    UpdatedDate        DATETIME        NULL,
    MsgKey             UNIQUEIDENTIFIER NULL,
	ExportFlag         INT             NULL
);
GO

-- Add a unique constraint to prevent duplicate outlet codes
ALTER TABLE abc_dwh.DimOutlet
ADD CONSTRAINT UQ_DimOutlet_Code UNIQUE (OutletCode);
GO
