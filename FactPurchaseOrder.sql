-- ====================================================================
-- Create External Table in Hive for FactPurchaseOrder
-- ====================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS abc_dwh.factpurchaseorder (
    -- Surrogate key from source extract (no IDENTITY in Hive)
    FactPOKey          BIGINT,

    -- Foreign keys (logical only in Hive)
    OrderDateKey       INT,               
    ExpectedDateKey    INT,               
    SupplierKey        INT,               
    ProductKey         INT,               
    OutletKey          INT,               

    -- Degenerate dimensions
    PONumber           STRING,            
    POLineNumber       INT,               

    -- Measures
    OrderQty           DECIMAL(18,4),
    ReceivedQty        DECIMAL(18,4),
    CancelledQty       DECIMAL(18,4),

    UnitCost           DECIMAL(19,4),     

    CurrencyCode       STRING,
    UOM                STRING,

    CreatedDate        TIMESTAMP,
    MsgKey             STRING,
    ExportFlag         INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/abc_dwh/factpurchaseorder'
TBLPROPERTIES (
    'skip.header.line.count'='1',
    'external.table.purge'='true',
    'comment'='External table for FactPurchaseOrder loaded from exported DWH CSV file'
);


-- HDFS prep & load
hdfs dfs -mkdir -p /user/abc_dwh/factpurchaseorder
hdfs dfs -put FactPurchaseOrder.csv /user/abc_dwh/factpurchaseorder/


-- Verify data load
SELECT COUNT(*) AS RecordCount FROM abc_dwh.factpurchaseorder;


CREATE EXTERNAL TABLE factpurchaseorder (
    FactPOKey          BIGINT,    
    OrderDateKey       INT,               
    ExpectedDateKey    INT,               
    SupplierKey        INT,               
    ProductKey         INT,               
    OutletKey          INT,               
    PONumber           STRING,            
    POLineNumber       INT,               
    OrderQty           DECIMAL(18,4),
    ReceivedQty        DECIMAL(18,4),
    CancelledQty       DECIMAL(18,4),
    UnitCost           DECIMAL(19,4),    
    CurrencyCode       STRING,
    UOM                STRING,
    CreatedDate        TIMESTAMP,
    MsgKey             STRING,
    ExportFlag         INT                
)
STORED AS PARQUET
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/FactPurchaseOrder.csv';


CREATE EXTERNAL TABLE IF NOT EXISTS factpurchaseorder_raw (
    FactPOKey          BIGINT,    
    OrderDateKey       INT,               
    ExpectedDateKey    INT,               
    SupplierKey        INT,               
    ProductKey         INT,               
    OutletKey          INT,               
    PONumber           STRING,            
    POLineNumber       INT,               
    OrderQty           DECIMAL(18,4),
    ReceivedQty        DECIMAL(18,4),
    CancelledQty       DECIMAL(18,4),
    UnitCost           DECIMAL(19,4),    
    CurrencyCode       STRING,
    UOM                STRING,
    CreatedDate        TIMESTAMP,
    MsgKey             STRING,
    ExportFlag         INTT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar"="|",
  "quoteChar"="\"",
  "escapeChar"="\\"
)
STORED AS TEXTFILE
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/factpurchaseorder/'
TBLPROPERTIES ("skip.header.line.count"="1");


LOAD DATA INPATH 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/FactPurchaseOrder.csv' into table factpurchaseorder_raw;

SELECT * FROM factpurchaseorder_raw LIMIT 10;