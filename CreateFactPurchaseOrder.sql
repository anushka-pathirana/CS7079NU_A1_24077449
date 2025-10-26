-- ==========================================================
-- Fact: Purchase Orders (line-level)
-- ==========================================================
IF OBJECT_ID('abc_dwh.FactPurchaseOrder','U') IS NOT NULL
    DROP TABLE abc_dwh.FactPurchaseOrder;
GO

CREATE TABLE abc_dwh.FactPurchaseOrder
(
    FactPOKey           BIGINT IDENTITY(1,1) PRIMARY KEY,

    -- Foreign keys
    OrderDateKey        INT         NOT NULL,  -- -> DimDate.DateKey (PO create date)
    ExpectedDateKey     INT         NULL,      -- -> DimDate.DateKey (ETA / promised date)
    SupplierKey         INT         NOT NULL,  -- -> DimSupplier.SupplierKey
    ProductKey          INT         NOT NULL,  -- -> DimProduct.ProductKey
    OutletKey           INT         NULL,      -- -> DimOutlet.OutletKey (ordering site/DC)

    -- Degenerate dims (document identifiers)
    PONumber            VARCHAR(50) NOT NULL,
    POLineNumber        INT         NOT NULL,

    -- Measures
    OrderQty            DECIMAL(18,4) NOT NULL DEFAULT 0,
    ReceivedQty         DECIMAL(18,4) NOT NULL DEFAULT 0,
    CancelledQty        DECIMAL(18,4) NOT NULL DEFAULT 0,

    UnitCost            DECIMAL(19,4) NULL,  -- cost per ordered unit (base currency)
    ExtendedCost        AS (ISNULL(UnitCost,0) * ISNULL(OrderQty,0)) PERSISTED,

    CurrencyCode        VARCHAR(10) NULL,     -- degenerate if no DimCurrency
    UOM                 VARCHAR(20) NULL,

    CreatedDate         DATETIME    NOT NULL DEFAULT GETDATE(),
    MsgKey              UNIQUEIDENTIFIER NULL,
	ExportFlag          INT             NULL
);
GO

-- Foreign keys
ALTER TABLE abc_dwh.FactPurchaseOrder
  ADD CONSTRAINT FK_FPO_OrderDate   FOREIGN KEY (OrderDateKey)   REFERENCES abc_dwh.DimDate(DateKey),
      CONSTRAINT FK_FPO_ExpectedDate FOREIGN KEY (ExpectedDateKey) REFERENCES abc_dwh.DimDate(DateKey),
      CONSTRAINT FK_FPO_Supplier    FOREIGN KEY (SupplierKey)    REFERENCES abc_dwh.DimSupplier(SupplierKey),
      CONSTRAINT FK_FPO_Product     FOREIGN KEY (ProductKey)     REFERENCES abc_dwh.DimProduct(ProductKey),
      CONSTRAINT FK_FPO_Outlet      FOREIGN KEY (OutletKey)      REFERENCES abc_dwh.DimOutlet(OutletKey);
GO

-- Helpful indexes
CREATE UNIQUE INDEX UX_FPO_PONumberLine ON abc_dwh.FactPurchaseOrder (PONumber, POLineNumber);
CREATE INDEX IX_FPO_OrderDateKey   ON abc_dwh.FactPurchaseOrder (OrderDateKey);
CREATE INDEX IX_FPO_SupplierKey    ON abc_dwh.FactPurchaseOrder (SupplierKey);
CREATE INDEX IX_FPO_ProductKey     ON abc_dwh.FactPurchaseOrder (ProductKey);
CREATE INDEX IX_FPO_OutletKey      ON abc_dwh.FactPurchaseOrder (OutletKey);
GO
