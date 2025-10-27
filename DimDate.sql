-- ====================================================================
-- Create External Table in Hive for DimDate
-- ====================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS abc_dwh.dimdate (
    DateKey            INT,
    FullDate           TIMESTAMP,
    DayOfWeek          INT,
    DayName            STRING,
    DayOfMonth          INT,
    DayOfYear          INT,
    WeekNumber          INT,
    MonthOfYear        INT,
    MonthName          STRING,
    CalendarQuarter    INT,
    CalendarYear       INT,
    IsWeekend           BOOLEAN,
    FiscalMonth         INT,
    FiscalQuarter         INT,
    FiscalYear         INT,
    CreatedDate           TIMESTAMP,
    MsgKey              STRING,
    ExportFlag          INT  
    
    
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/abc_dwh/dimdate'
TBLPROPERTIES (
    'skip.header.line.count'='1',
    'external.table.purge'='true',
    'comment'='External table for DimDate loaded from exported DWH CSV file'
);

-- HDFS Path

hdfs dfs -mkdir -p /user/abc_dwh/dimdate
hdfs dfs -put DimDate.csv /user/abc_dwh/dimdate/


-- Verification
SELECT * FROM abc_dwh.dimdate LIMIT 10;


CREATE EXTERNAL TABLE dimdate (
    DateKey            INT,
    FullDate           TIMESTAMP,
    DayOfWeek          INT,
    DayName            STRING,
    DayOfMonth          INT,
    DayOfYear          INT,
    WeekNumber          INT,
    MonthOfYear        INT,
    MonthName          STRING,
    CalendarQuarter    INT,
    CalendarYear       INT,
    IsWeekend           BOOLEAN,
    FiscalMonth         INT,
    FiscalQuarter         INT,
    FiscalYear         INT,    
    CreatedDate            TIMESTAMP,
    MsgKey              STRING,
    ExportFlag          INT                  
)
STORED AS PARQUET
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/DimDate.csv';


-- EXTERNAL RAW table that reads your pipe-delimited CSVs directly from GCS
CREATE EXTERNAL TABLE IF NOT EXISTS dimdate_raw (
    DateKey            INT,
    FullDate           TIMESTAMP,
    DayOfWeek          INT,
    DayName            STRING,
    DayOfMonth          INT,
    DayOfYear          INT,
    WeekNumber          INT,
    MonthOfYear        INT,
    MonthName          STRING,
    CalendarQuarter    INT,
    CalendarYear       INT,
    IsWeekend           BOOLEAN,
    FiscalMonth         INT,
    FiscalQuarter         INT,
    FiscalYear         INT,    
    CreatedDate            TIMESTAMP,
    MsgKey              STRING,
    ExportFlag          INT 
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar"="|",
  "quoteChar"="\"",
  "escapeChar"="\\"
)
STORED AS TEXTFILE
LOCATION 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/dwh/dimdate/'
TBLPROPERTIES ("skip.header.line.count"="1");


LOAD DATA INPATH 'gs://dataproc-staging-us-central1-693796076775-f4rq2rni/abc/DimDate.csv' into table dimdate_raw;

SELECT * FROM dimdate_raw LIMIT 10;

