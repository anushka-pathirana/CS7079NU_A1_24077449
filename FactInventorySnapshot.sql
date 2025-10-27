-- ====================================================================
-- Create External Table in Hive for FactInventorySnapshot
-- ====================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS abc_dwh.factinventorysnapshot (
    FactInvSnapKey     BIGINT,              
    SnapshotDateKey    INT,                 
    ProductKey         INT,                 
    OutletKey          INT,                 

    QtyOnHand          DECIMAL(18,4),       
    QtyAllocated       DECIMAL(18,4),       
    QtyOnOrder         DECIMAL(18,4),       
    AvgUnitCost        DECIMAL(19,4),       

    CreatedDate        TIMESTAMP,           
    MsgKey             STRING,              
    ExportFlag         INT                  
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/abc_dwh/factinventorysnapshot'
TBLPROPERTIES (
    'skip.header.line.count'='1',
    'external.table.purge'='true',
    'comment'='External table for FactInventorySnapshot loaded from exported DWH CSV file'
);

-- Prepare HDFS Directory and Load File 
hdfs dfs -mkdir -p /user/abc_dwh/factinventorysnapshot
hdfs dfs -put FactInventorySnapshot.csv /user/abc_dwh/factinventorysnapshot/


-- Verify data load
SELECT COUNT(*) AS RecordCount FROM abc_dwh.factinventorysnapshot;

SELECT SnapshotDateKey, ProductKey, QtyOnHand, AvgUnitCost
FROM abc_dwh.factinventorysnapshot
LIMIT 10;


CREATE EXTERNAL TABLE factinventorysnapshot (
    FactInvSnapKey     BIGINT,              
    SnapshotDateKey    INT,                 
    ProductKey         INT,                 
    OutletKey          INT,                 
    QtyOnHand          DECIMAL(18,4),       
    QtyAllocated       DECIMAL(18,4),       
    QtyOnOrder         DECIMAL(18,4),       
    AvgUnitCost        DECIMAL(19,4),       
    CreatedDate        TIMESTAMP,           
    MsgKey             STRING,              
    ExportFlag         INT                
)
STORED AS PARQUET
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/FactInventorySnapshot.csv';