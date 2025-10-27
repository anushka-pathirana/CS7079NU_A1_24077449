-- ====================================================================
-- Create External Table in Hive for DimProductType
-- ====================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS abc_dwh.dimproducttype (
    ProductTypeKey     INT,                
    ProductTypeName    STRING,             
    ProductTypeDesc    STRING,             
    CategoryGroup      STRING,             
    IsActive           BOOLEAN,            
    CreatedDate        TIMESTAMP,          
    UpdatedDate        TIMESTAMP,          
    MsgKey             STRING,             
    ExportFlag         INT                 
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/abc_dwh/dimproducttype'
TBLPROPERTIES (
    'skip.header.line.count'='1',
    'external.table.purge'='true',
    'comment'='External table for DimProductType loaded from exported DWH CSV file'
);

--Prepare HDFS Directory
hdfs dfs -mkdir -p /user/abc_dwh/dimproducttype
hdfs dfs -put DimProductType.csv /user/abc_dwh/dimproducttype/


--Verification Query
SELECT * FROM abc_dwh.dimproducttype LIMIT 10;


CREATE EXTERNAL TABLE dimproducttype (
    ProductTypeKey     INT,                
    ProductTypeName    STRING,             
    ProductTypeDesc    STRING,             
    CategoryGroup      STRING,             
    IsActive           BOOLEAN,            
    CreatedDate        TIMESTAMP,          
    UpdatedDate        TIMESTAMP,          
    MsgKey             STRING,             
    ExportFlag         INT                  
)
STORED AS PARQUET
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/DimProductType.csv';


-- EXTERNAL RAW table that reads your pipe-delimited CSVs directly from GCS
CREATE EXTERNAL TABLE IF NOT EXISTS dimproducttype_raw (
    ProductTypeKey     INT,                
    ProductTypeName    STRING,             
    ProductTypeDesc    STRING,             
    CategoryGroup      STRING,             
    IsActive           BOOLEAN,            
    CreatedDate        TIMESTAMP,          
    UpdatedDate        TIMESTAMP,          
    MsgKey             STRING,             
    ExportFlag         INT  
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar"="|",
  "quoteChar"="\"",
  "escapeChar"="\\"
)
STORED AS TEXTFILE
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/dimproducttype/'
TBLPROPERTIES ("skip.header.line.count"="1");


LOAD DATA INPATH 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/DimProductType.csv' into table dimproducttype_raw;

SELECT * FROM dimproducttype_raw LIMIT 10;