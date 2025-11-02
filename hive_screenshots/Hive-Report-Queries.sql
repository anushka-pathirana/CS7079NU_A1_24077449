
--- Report 01
--- A daily stock levels of all products for the last month.

CREATE TABLE IF NOT EXISTS inventorysnapshotreport (
     snapshotdatekey INT,
     productsku STRING,
     productname STRING,
     qtyonhand DECIMAL(18,4)
)
STORED AS PARQUET;



INSERT OVERWRITE TABLE inventorysnapshotreport
 SELECT 
     a.snapshotdatekey,
     b.productsku,
     b.productname,
     a.qtyonhand
 FROM 
     factinventorysnapshot a
 JOIN 
     dimproduct b 
 ON 
     a.productkey = b.productkey;

SELECT * FROM inventorysnapshotreport LIMIT 10;


--- Report 02
--weekly report of all products with their minimum stock levels

CREATE TABLE IF NOT EXISTS weekly_product_stock_report (
    calendaryear INT,
    weeknumber INT,
    productsku STRING,
    productname STRING,
    qty_onhand_total DECIMAL(18,4)
)
STORED AS PARQUET;

INSERT OVERWRITE TABLE weekly_product_stock_report
SELECT
    d.calendaryear,
    d.weeknumber,
    p.productsku,
    p.productname,
    SUM(f.qtyonhand) AS qty_onhand_total
FROM
    factinventorysnapshot f
JOIN 
    dimdate d
    ON d.datekey = f.snapshotdatekey
JOIN 
    dimproduct p
    ON p.productkey = f.productkey
GROUP BY 
    d.calendaryear,
    d.weeknumber,
    p.productsku,
    p.productname;



    SELECT * FROM weekly_product_stock_report LIMIT 10;


--- Report 03
-- analyze stock levels by Brand, Product Type, or Supplier

------------------------------ By Brand

-- Step 1: Create table to store summarized stock by brand
CREATE TABLE IF NOT EXISTS brand_stock_summary (
    brandname STRING,
    qtyonhand DECIMAL(18,4)
)
STORED AS PARQUET;

-- Step 2: Insert summarized data into the new table
INSERT OVERWRITE TABLE brand_stock_summary
SELECT
    b.brandname,
    SUM(f.qtyonhand) AS qtyonhand
FROM 
    factinventorysnapshot f
JOIN 
    dimproduct p 
    ON p.productkey = f.productkey
JOIN 
    dimbrand b 
    ON b.brandkey = p.brandkey
-- Optional: Filter for specific date range
-- WHERE f.snapshotdatekey BETWEEN 20250101 AND 20251231
GROUP BY 
    b.brandname
ORDER BY 
    qtyonhand DESC;

-- Step 3: Validate data
SELECT * FROM brand_stock_summary LIMIT 10;



------------------------------ By Product Type

-- Step 1: Create a table to store summarized stock by product type
CREATE TABLE IF NOT EXISTS producttype_stock_summary (
    producttypename STRING,
    qtyonhand DECIMAL(18,4)
)
STORED AS PARQUET;

-- Step 2: Insert summarized data into the table
INSERT OVERWRITE TABLE producttype_stock_summary
SELECT
    pt.producttypename,
    SUM(f.qtyonhand) AS qtyonhand
FROM 
    factinventorysnapshot f
JOIN 
    dimproduct p 
    ON p.productkey = f.productkey
JOIN 
    dimproducttype pt 
    ON pt.producttypekey = p.producttypekey
-- Optional date filter (uncomment if needed)
-- WHERE f.snapshotdatekey BETWEEN 20250101 AND 20251231
GROUP BY 
    pt.producttypename
ORDER BY 
    qtyonhand DESC;

-- Step 3: Validate output
SELECT * FROM producttype_stock_summary LIMIT 10;


------------------------------ By supplier

-- Step 1: Create a table to store summarized stock by supplier
CREATE TABLE IF NOT EXISTS supplier_stock_summary (
    suppliername STRING,
    qtyonhand DECIMAL(18,4)
)
STORED AS PARQUET;

-- Step 2: Insert summarized data into the new table
INSERT OVERWRITE TABLE supplier_stock_summary
SELECT
    s.suppliername,
    SUM(f.qtyonhand) AS qtyonhand
FROM 
    factinventorysnapshot f
JOIN 
    dimproduct p 
    ON p.productkey = f.productkey
JOIN 
    dimsupplier s 
    ON s.supplierkey = p.supplierkey
-- Optional filter: uncomment to limit by date
-- WHERE f.snapshotdatekey BETWEEN 20250101 AND 20251231
GROUP BY 
    s.suppliername
ORDER BY 
    qtyonhand DESC;

-- Step 3: Verify data
SELECT * FROM supplier_stock_summary LIMIT 10;


--- Report 04
--produce daily and weekly sent/received stock orders  
--(abc_dwh.FactPurchaseOrder, abc_dwh.FactReceipt, abc_dwh.DimDate).

-- 1) Create the destination table
CREATE TABLE IF NOT EXISTS daily_po_receipt_summary (
  dt                DATE,
  sentqty           DECIMAL(18,4),
  sentorders        BIGINT,
  sentlines         BIGINT,
  receivedqty       DECIMAL(18,4),
  receiveddocs      BIGINT,
  receivedlines     BIGINT
)
STORED AS PARQUET;

-- 2) Load data (converted from your MS SQL)
INSERT OVERWRITE TABLE daily_po_receipt_summary
SELECT
  to_date(d.fulldate)                                        AS dt,                     -- [Date]
  SUM(COALESCE(po.orderqty, 0))                              AS sentqty,                -- Sent (POs)
  COUNT(DISTINCT po.ponumber)                                AS sentorders,
  COUNT(DISTINCT CONCAT(po.ponumber, ':', po.polinenumber))  AS sentlines,
  -- Received (Receipts)
  SUM(COALESCE(rc.receivedqty, 0))                           AS receivedqty,
  COUNT(DISTINCT rc.receiptnumber)                           AS receiveddocs,
  COUNT(DISTINCT CONCAT(rc.receiptnumber, ':', rc.ponumber, ':', rc.polinenumber)) AS receivedlines
FROM
  dimdate d
LEFT JOIN factpurchaseorder po
       ON po.orderdatekey = d.datekey
LEFT JOIN factreceipt rc
       ON rc.receiptdatekey = d.datekey
WHERE
  po.factpokey IS NOT NULL               -- keeps only dates that have POs (matches your MS SQL filter)
GROUP BY
  to_date(d.fulldate);


  SELECT * FROM daily_po_receipt_summary ORDER BY dt LIMIT 100;


 --- Report 05
 --analyze received stock orders by Supplier and by Month . 
--It shows quantities, document counts, distinct PO lines, and total received value.

-- 1) Create the destination table
CREATE TABLE IF NOT EXISTS supplier_monthly_receipts (
  suppliername     STRING,
  calendaryear     INT,
  monthofyear      INT,
  monthname        STRING,
  yearmonth        STRING,          -- e.g., '2025-10'
  receivedqty      DECIMAL(18,4),
  receivedvalue    DECIMAL(19,4),
  receiptdocs      BIGINT,
  distinctpolines  BIGINT,
  distinctproducts BIGINT
)
STORED AS PARQUET;

-- 2) Load data (Hive conversion of your MS SQL)
INSERT OVERWRITE TABLE supplier_monthly_receipts
SELECT
  s.suppliername,
  d.calendaryear,
  d.monthofyear,
  d.monthname,
  date_format(to_date(d.fulldate), 'yyyy-MM')                                  AS yearmonth,   -- CONVERT(char(7), d.FullDate, 120)
  -- KPIs
  SUM(COALESCE(r.receivedqty, 0))                                              AS receivedqty,     -- SUM(ISNULL(...))
  SUM(COALESCE(r.receivedqty, 0) * COALESCE(r.unitcost, 0))                    AS receivedvalue,
  COUNT(DISTINCT r.receiptnumber)                                              AS receiptdocs,
  COUNT(DISTINCT CONCAT(r.ponumber, ':', r.polinenumber))                      AS distinctpolines,
  COUNT(DISTINCT r.productkey)                                                 AS distinctproducts
FROM abc_dwh.dimdate d
LEFT JOIN abc_dwh.factreceipt r
       ON r.receiptdatekey = d.datekey
LEFT JOIN abc_dwh.dimsupplier s
       ON s.supplierkey = r.supplierkey
WHERE s.suppliername IS NOT NULL     -- keeps only rows with a supplier (acts like filtering to matched receipts)
GROUP BY
  s.suppliername, d.calendaryear, d.monthofyear, d.monthname,
  date_format(to_date(d.fulldate), 'yyyy-MM')
ORDER BY
  s.suppliername, d.calendaryear, d.monthofyear;

-- 3) Quick check
SELECT * FROM supplier_monthly_receipts ORDER BY suppliername, calendaryear, monthofyear LIMIT 50;



