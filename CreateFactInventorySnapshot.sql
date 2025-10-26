-- ==========================================================
-- Fact: Inventory Snapshot (daily EoD by Product/Outlet)
-- ==========================================================
IF OBJECT_ID('abc_dwh.FactInventorySnapshot','U') IS NOT NULL
    DROP TABLE abc_dwh.FactInventorySnapshot;
GO

CREATE TABLE abc_dwh.FactInventorySnapshot
(
    FactInvSnapKey      BIGINT IDENTITY(1,1) PRIMARY KEY,

    SnapshotDateKey     INT         NOT NULL,  -- -> DimDate.DateKey (EoD date)
    ProductKey          INT         NOT NULL,  -- -> DimProduct
    OutletKey           INT         NOT NULL,  -- -> DimOutlet

    -- Measures
    QtyOnHand           DECIMAL(18,4) NOT NULL DEFAULT 0,
    QtyAllocated        DECIMAL(18,4) NOT NULL DEFAULT 0,
    QtyOnOrder          DECIMAL(18,4) NOT NULL DEFAULT 0,
    AvgUnitCost         DECIMAL(19,4) NULL,   -- optional moving average
    InventoryValue      AS (ISNULL(QtyOnHand,0) * ISNULL(AvgUnitCost,0)) PERSISTED,

    CreatedDate         DATETIME     NOT NULL DEFAULT GETDATE(),
    MsgKey              UNIQUEIDENTIFIER NULL,
	ExportFlag          INT             NULL
);
GO

ALTER TABLE abc_dwh.FactInventorySnapshot
  ADD CONSTRAINT FK_FIS_Date    FOREIGN KEY (SnapshotDateKey) REFERENCES abc_dwh.DimDate(DateKey),
      CONSTRAINT FK_FIS_Product FOREIGN KEY (ProductKey)      REFERENCES abc_dwh.DimProduct(ProductKey),
      CONSTRAINT FK_FIS_Outlet  FOREIGN KEY (OutletKey)       REFERENCES abc_dwh.DimOutlet(OutletKey);
GO

-- Uniqueness: one snapshot per product/outlet/date
CREATE UNIQUE INDEX UX_FIS_Date_Product_Outlet
  ON abc_dwh.FactInventorySnapshot (SnapshotDateKey, ProductKey, OutletKey);

-- Helpful indexes
CREATE INDEX IX_FIS_ProductKey ON abc_dwh.FactInventorySnapshot (ProductKey);
CREATE INDEX IX_FIS_OutletKey  ON abc_dwh.FactInventorySnapshot (OutletKey);
GO
