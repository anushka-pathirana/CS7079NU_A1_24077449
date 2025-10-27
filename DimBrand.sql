-- ====================================================================
-- Create External Table in Hive for DimBrand
-- ====================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS abc_dwh.dimbrand (
    BrandKey          INT,                
    BrandName         STRING,             
    BrandDescription  STRING,             
    CountryOfOrigin   STRING,             
    IsActive          BOOLEAN,            
    CreatedDate       TIMESTAMP,          
    UpdatedDate       TIMESTAMP,          
    MsgKey            STRING,             
    ExportFlag        INT                 
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/abc_dwh/dimbrand'
TBLPROPERTIES (
    'skip.header.line.count'='1',
    'external.table.purge'='true',
    'comment'='External table for DimBrand loaded from exported DWH CSV file'
);
-- HDFS directory setup
hdfs dfs -mkdir -p /user/abc_dwh/dimbrand
hdfs dfs -put DimBrand.csv /user/abc_dwh/dimbrand/


-- Verification

SELECT * FROM abc_dwh.dimbrand LIMIT 10;


CREATE EXTERNAL TABLE dimbrand (
    BrandKey          INT,                
    BrandName         STRING,             
    BrandDescription  STRING,             
    CountryOfOrigin   STRING,             
    IsActive          BOOLEAN,            
    CreatedDate       TIMESTAMP,          
    UpdatedDate       TIMESTAMP,          
    MsgKey            STRING,             
    ExportFlag        INT                 
)
STORED AS PARQUET
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/DimBrand.csv';

CREATE EXTERNAL TABLE dimbrand (
    BrandKey          INT,                
    BrandName         STRING,             
    BrandDescription  STRING,             
    CountryOfOrigin   STRING,             
    IsActive          BOOLEAN,            
    CreatedDate       TIMESTAMP,          
    UpdatedDate       TIMESTAMP,          
    MsgKey            STRING,             
    ExportFlag        INT                 
)
STORED AS PARQUET
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/DimBrand.csv';


-- EXTERNAL RAW table that reads your pipe-delimited CSVs directly from GCS
CREATE EXTERNAL TABLE IF NOT EXISTS dimbrand_raw (
    BrandKey          INT,                
    BrandName         STRING,             
    BrandDescription  STRING,             
    CountryOfOrigin   STRING,             
    IsActive          BOOLEAN,            
    CreatedDate       TIMESTAMP,          
    UpdatedDate       TIMESTAMP,          
    MsgKey            STRING,             
    ExportFlag        INT 
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar"="|",
  "quoteChar"="\"",
  "escapeChar"="\\"
)
STORED AS TEXTFILE
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/dimbrand/'
TBLPROPERTIES ("skip.header.line.count"="1");

SELECT * FROM dimbrand_raw LIMIT 10;
gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/DimBrand.csv

LOAD DATA INPATH 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/DimBrand.csv' into table dimbrand_raw;

dimbrand_raw