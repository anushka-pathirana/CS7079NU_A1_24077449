-- ====================================================================
-- Create External Table in Hive for DimOutlet
-- ====================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS abc_dwh.dimoutlet (
    OutletKey        INT,                
    OutletCode       STRING,             
    OutletName       STRING,             
    OutletType       STRING,             
    AddressLine1     STRING,             
    AddressLine2     STRING,             
    City             STRING,             
    StateProvince    STRING,             
    PostCode         STRING,             
    Country          STRING,             
    Phone            STRING,             
    Email            STRING,             
    ManagerName      STRING,             
    IsActive         BOOLEAN,            
    CreatedDate      TIMESTAMP,          
    UpdatedDate      TIMESTAMP,          
    MsgKey           STRING,             
    ExportFlag       INT                 
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/abc_dwh/dimoutlet'
TBLPROPERT

--Create directory and load file in HDFS
hdfs dfs -mkdir -p /user/abc_dwh/dimoutlet
hdfs dfs -put DimOutlet.csv /user/abc_dwh/dimoutlet/

--Verify data
SELECT OutletCode, OutletName, City, IsActive FROM abc_dwh.dimoutlet LIMIT 10;

CREATE EXTERNAL TABLE dimoutlet (
    OutletKey        INT,                
    OutletCode       STRING,             
    OutletName       STRING,             
    OutletType       STRING,             
    AddressLine1     STRING,             
    AddressLine2     STRING,             
    City             STRING,             
    StateProvince    STRING,             
    PostCode         STRING,             
    Country          STRING,             
    Phone            STRING,             
    Email            STRING,             
    ManagerName      STRING,             
    IsActive         BOOLEAN,            
    CreatedDate      TIMESTAMP,          
    UpdatedDate      TIMESTAMP,          
    MsgKey           STRING,             
    ExportFlag       INT                  
)
STORED AS PARQUET
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/DimOutlet.csv';


-- EXTERNAL RAW table that reads your pipe-delimited CSVs directly from GCS
CREATE EXTERNAL TABLE IF NOT EXISTS dimoutlet_raw (
    OutletKey        INT,                
    OutletCode       STRING,             
    OutletName       STRING,             
    OutletType       STRING,             
    AddressLine1     STRING,             
    AddressLine2     STRING,             
    City             STRING,             
    StateProvince    STRING,             
    PostCode         STRING,             
    Country          STRING,             
    Phone            STRING,             
    Email            STRING,             
    ManagerName      STRING,             
    IsActive         BOOLEAN,            
    CreatedDate      TIMESTAMP,          
    UpdatedDate      TIMESTAMP,          
    MsgKey           STRING,             
    ExportFlag       INT 
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar"="|",
  "quoteChar"="\"",
  "escapeChar"="\\"
)
STORED AS TEXTFILE
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/dimoutlet/'
TBLPROPERTIES ("skip.header.line.count"="1");


LOAD DATA INPATH 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/DimOutlet.csv' into table dimoutlet_raw;

SELECT * FROM dimoutlet_raw LIMIT 10;