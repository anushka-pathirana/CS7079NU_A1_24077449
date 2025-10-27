-- ====================================================================
-- Create External Table in Hive for DimProduct
-- ====================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS abc_dwh.dimproduct (
    ProductKey         INT,                
    ProductSKU         STRING,             
    ProductName        STRING,             
    Description        STRING,             
    Condition          STRING,             
    ProductTypeKey     INT,                
    BrandKey           INT,                
    SupplierKey        INT,                
    Tags               STRING,             
    CostPrice          DECIMAL(18,2),      
    RetailPrice        DECIMAL(18,2),      
    CurrentStockLevel  INT,                
    DateCreatedAt      DATE,               
    DateDiscontinuedAt DATE,               
    IsActive           BOOLEAN,            
    CreatedDate        TIMESTAMP,          
    UpdatedDate        TIMESTAMP,          
    MsgKey             STRING,             
    ExportFlag         INT                 
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/abc_dwh/dimproduct'
TBLPROPERTIES (
    'skip.header.line.count'='1',
    'external.table.purge'='true',
    'comment'='External table for DimProduct loaded from exported DWH CSV file'
);


-- HDFS directory setup
hdfs dfs -mkdir -p /user/abc_dwh/dimproduct
hdfs dfs -put DimProduct.csv /user/abc_dwh/dimproduct/

--  Validation
SELECT ProductSKU, ProductName, CostPrice, RetailPrice FROM abc_dwh.dimproduct LIMIT 10;

CREATE EXTERNAL TABLE dimproduct (
    ProductKey         INT,                
    ProductSKU         STRING,             
    ProductName        STRING,             
    Description        STRING,             
    Condition          STRING,             
    ProductTypeKey     INT,                
    BrandKey           INT,                
    SupplierKey        INT,                
    Tags               STRING,             
    CostPrice          DECIMAL(18,2),      
    RetailPrice        DECIMAL(18,2),      
    CurrentStockLevel  INT,                
    DateCreatedAt      DATE,               
    DateDiscontinuedAt DATE,               
    IsActive           BOOLEAN,            
    CreatedDate        TIMESTAMP,          
    UpdatedDate        TIMESTAMP,          
    MsgKey             STRING,             
    ExportFlag         INT                 
)
STORED AS PARQUET
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/DimProduct.csv';



-- EXTERNAL RAW table that reads your pipe-delimited CSVs directly from GCS
CREATE EXTERNAL TABLE IF NOT EXISTS dimproduct_raw (
    ProductKey         INT,                
    ProductSKU         STRING,             
    ProductName        STRING,             
    Description        STRING,             
    Condition          STRING,             
    ProductTypeKey     INT,                
    BrandKey           INT,                
    SupplierKey        INT,                
    Tags               STRING,             
    CostPrice          DECIMAL(18,2),      
    RetailPrice        DECIMAL(18,2),      
    CurrentStockLevel  INT,                
    DateCreatedAt      DATE,               
    DateDiscontinuedAt DATE,               
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
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/dimproduct/'
TBLPROPERTIES ("skip.header.line.count"="1");


LOAD DATA INPATH 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/DimProduct.csv' into table dimproduct_raw;

SELECT * FROM dimproduct_raw LIMIT 10;