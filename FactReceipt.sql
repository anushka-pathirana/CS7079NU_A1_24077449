-- ====================================================================
-- Create External Table in Hive for FactReceipt
-- ====================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS abc_dwh.factreceipt (
    FactReceiptKey      BIGINT,             
    ReceiptDateKey      INT,                 
    SupplierKey         INT,                 
    ProductKey          INT,                 
    OutletKey           INT,                 

    ReceiptNumber       STRING,              
    PONumber            STRING,              
    POLineNumber        INT,                 

    ReceivedQty         DECIMAL(18,4),       
    RejectedQty         DECIMAL(18,4),       
    UnitCost            DECIMAL(19,4),       

    BatchLot            STRING,              
    UOM                 STRING,              

    CreatedDate         TIMESTAMP,           
    MsgKey              STRING,              
    ExportFlag          INT                  
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/abc_dwh/factreceipt'
TBLPROPERTIES (
    'skip.header.line.count'='1',
    'external.table.purge'='true',

--  HDFS Directory Setup
hdfs dfs -mkdir -p /user/abc_dwh/factreceipt
hdfs dfs -put FactReceipt.csv /user/abc_dwh/factreceipt/


-- Verify data load
SELECT COUNT(*) AS RecordCount FROM abc_dwh.factreceipt;

SELECT ReceiptNumber, ProductKey, SupplierKey, ReceivedQty, UnitCost
FROM abc_dwh.factreceipt
LIMIT 10;



CREATE EXTERNAL TABLE factreceipt (
    FactReceiptKey      BIGINT,             
    ReceiptDateKey      INT,                 
    SupplierKey         INT,                 
    ProductKey          INT,                 
    OutletKey           INT,                
    ReceiptNumber       STRING,              
    PONumber            STRING,              
    POLineNumber        INT,                 
    ReceivedQty         DECIMAL(18,4),       
    RejectedQty         DECIMAL(18,4),       
    UnitCost            DECIMAL(19,4),       
    BatchLot            STRING,              
    UOM                 STRING,              
    CreatedDate         TIMESTAMP,           
    MsgKey              STRING,              
    ExportFlag          INT               
)
STORED AS PARQUET
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/FactReceipt.csv';