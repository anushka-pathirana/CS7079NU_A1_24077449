-- ==========================================================
-- Fact: Receipts (Goods Received) line-level
-- ==========================================================
IF OBJECT_ID('abc_dwh.FactReceipt','U') IS NOT NULL
    DROP TABLE abc_dwh.FactReceipt;
GO

CREATE TABLE abc_dwh.FactReceipt
(
    FactReceiptKey      BIGINT IDENTITY(1,1) PRIMARY KEY,

    -- Foreign keys
    ReceiptDateKey      INT         NOT NULL,  -- -> DimDate.DateKey (actual GRN date)
    SupplierKey         INT         NOT NULL,  -- -> DimSupplier
    ProductKey          INT         NOT NULL,  -- -> DimProduct
    OutletKey           INT         NOT NULL,  -- Receiving site/DC

    -- Degenerate dims
    ReceiptNumber       NVARCHAR(50) NOT NULL,  -- GRN/ASN/Receipt ID
    PONumber            NVARCHAR(50) NULL,      -- Link to PO if available
    POLineNumber        INT         NULL,

    -- Measures
    ReceivedQty         DECIMAL(18,4) NOT NULL DEFAULT 0,
    RejectedQty         DECIMAL(18,4) NOT NULL DEFAULT 0,
    UnitCost            DECIMAL(19,4) NULL,    -- landed or invoice cost if known
    ExtendedCost        AS (ISNULL(UnitCost,0) * ISNULL(ReceivedQty,0)) PERSISTED,

    BatchLot            NVARCHAR(50)  NULL,
    UOM                 NVARCHAR(20)  NULL,

    CreatedDate         DATETIME     NOT NULL DEFAULT GETDATE(),
    MsgKey              UNIQUEIDENTIFIER NULL,
	ExportFlag          INT             NULL

);
GO

ALTER TABLE abc_dwh.FactReceipt
  ADD CONSTRAINT FK_FR_ReceiptDate FOREIGN KEY (ReceiptDateKey) REFERENCES abc_dwh.DimDate(DateKey),
      CONSTRAINT FK_FR_Supplier    FOREIGN KEY (SupplierKey)    REFERENCES abc_dwh.DimSupplier(SupplierKey),
      CONSTRAINT FK_FR_Product     FOREIGN KEY (ProductKey)     REFERENCES abc_dwh.DimProduct(ProductKey),
      CONSTRAINT FK_FR_Outlet      FOREIGN KEY (OutletKey)      REFERENCES abc_dwh.DimOutlet(OutletKey);
GO

-- Helpful indexes
CREATE INDEX IX_FR_ReceiptDateKey ON abc_dwh.FactReceipt (ReceiptDateKey);
CREATE INDEX IX_FR_SupplierKey    ON abc_dwh.FactReceipt (SupplierKey);
CREATE INDEX IX_FR_ProductKey     ON abc_dwh.FactReceipt (ProductKey);
CREATE INDEX IX_FR_OutletKey      ON abc_dwh.FactReceipt (OutletKey);
CREATE INDEX IX_FR_ReceiptNumber  ON abc_dwh.FactReceipt (ReceiptNumber);
GO
