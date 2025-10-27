-- ====================================================================
-- Create External Table in Hive for DimSupplier
-- ====================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS abc_dwh.dimsupplier (
    SupplierKey        INT,               
    SupplierName       STRING,            
    Description        STRING,            
    Phone              STRING,            
    Email              STRING,            
    Fax                STRING,            
    FirstLineAddress   STRING,            
    PostCode           STRING,            
    City               STRING,            
    State              STRING,            
    CountryID          INT,               
    IsActive           BOOLEAN,           
    CreatedDate        TIMESTAMP,         
    UpdatedDate        TIMESTAMP,         
    MsgKey             STRING,            
    ExportFlag         INT                
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/abc_dwh/dimsupplier'
TBLPROPERTIES (
    'skip.header.line.count'='1',
    'external.table.purge'='true',
    'comment'='External table for DimSupplier loaded from exported DWH CSV file'
);

--Create HDFS directory and load CSV
hdfs dfs -mkdir -p /user/abc_dwh/dimsupplier
hdfs dfs -put DimSupplier.csv /user/abc_dwh/dimsupplier/

--Verify data after creation
SELECT SupplierKey, SupplierName, City, CountryID FROM abc_dwh.dimsupplier LIMIT 10;


CREATE EXTERNAL TABLE dimsupplier (
    SupplierKey        INT,               
    SupplierName       STRING,            
    Description        STRING,            
    Phone              STRING,            
    Email              STRING,            
    Fax                STRING,            
    FirstLineAddress   STRING,            
    PostCode           STRING,            
    City               STRING,            
    State              STRING,            
    CountryID          INT,               
    IsActive           BOOLEAN,           
    CreatedDate        TIMESTAMP,         
    UpdatedDate        TIMESTAMP,         
    MsgKey             STRING,            
    ExportFlag         INT                 
)
STORED AS PARQUET
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/DimSupplier.csv';


-- pig-script.pig

REGISTER /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-core.jar;

raw = LOAD 'gs://YOUR_BUCKET/input/sales.tsv' USING PigStorage('\t') 

      AS (sale_id:int, customer_id:int, region:chararray, amount:double, sale_date:chararray);

by_region = GROUP raw BY region;

region_totals = FOREACH by_region GENERATE group AS region, SUM(raw.amount) AS total_amount, COUNT(raw) AS cnt;

STORE region_totals INTO 'gs://YOUR_BUCKET/output/region_totals' USING PigStorage('\t');


-- EXTERNAL RAW table that reads your pipe-delimited CSVs directly from GCS
CREATE EXTERNAL TABLE IF NOT EXISTS dimsupplier_raw (
    SupplierKey        INT,               
    SupplierName       STRING,            
    Description        STRING,            
    Phone              STRING,            
    Email              STRING,            
    Fax                STRING,            
    FirstLineAddress   STRING,            
    PostCode           STRING,            
    City               STRING,            
    State              STRING,            
    CountryID          INT,               
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
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/dimsupplier/'
TBLPROPERTIES ("skip.header.line.count"="1");


LOAD DATA INPATH 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/DimSupplier.csv' into table dimsupplier_raw;

SELECT * FROM dimsupplier_raw LIMIT 10;