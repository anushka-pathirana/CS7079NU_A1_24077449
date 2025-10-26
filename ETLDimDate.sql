/*==========================================================
  ETL: Full Reload of abc_dwh.DimDate (2006–2026)
  - Deterministic weekday & names (no DATEFIRST/LANGUAGE deps)
  - Sunday = 1 … Saturday = 7
  - WeekNumber = Sunday-based
  - Fiscal parts configurable via @FiscalStartMonth
==========================================================*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;

DECLARE @StartDate        date = '2006-01-01';
DECLARE @EndDate          date = '2026-12-31';
DECLARE @FiscalStartMonth int  = 1;   -- e.g., 4 for April fiscal start

-- 1) Empty table (use DELETE WITH (TABLOCK) if FK refs block TRUNCATE)
DELETE abc_dwh.DimDate;
---TRUNCATE TABLE abc_dwh.DimDate; if needed

-- 2) Build tally → dates → calc, then insert
;WITH
E1(N) AS (SELECT 1 FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) v(n)),  -- 10
E2(N) AS (SELECT 1 FROM E1 a CROSS JOIN E1 b),                                   -- 100
E4(N) AS (SELECT 1 FROM E2 a CROSS JOIN E2 b),                                   -- 10,000
Tally(N) AS (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1)
           ROW_NUMBER() OVER (ORDER BY (SELECT 1)) - 1
    FROM E4
),
Dates AS (
    SELECT DATEADD(DAY, N, @StartDate) AS FullDate
    FROM Tally
),
Calc AS (
    SELECT
        d.FullDate,
        -- Deterministic DayOfWeek: 1=Sun … 7=Sat (anchor Sunday 2000-01-02)
        (((DATEDIFF(DAY, CONVERT(date,'2000-01-02'), d.FullDate) % 7) + 7) % 7) + 1 AS DayOfWeek,
        -- Sunday-based week number
        DATEDIFF(WEEK, DATEADD(DAY,-1, DATEFROMPARTS(YEAR(d.FullDate),1,1)), d.FullDate)  AS WeekNumber,
        DAY(d.FullDate)                         AS DayOfMonth,
        DATEPART(DAYOFYEAR, d.FullDate)         AS DayOfYear,
        MONTH(d.FullDate)                       AS MonthOfYear,
        DATEPART(QUARTER, d.FullDate)           AS CalendarQuarter,
        YEAR(d.FullDate)                        AS CalendarYear,
        -- Shift for fiscal calculations
        DATEADD(MONTH, -( @FiscalStartMonth - 1 ), d.FullDate) AS ShiftedFiscalDate
    FROM Dates d
)
INSERT INTO abc_dwh.DimDate
(
    DateKey,
    FullDate,
    DayOfWeek,
    DayName,
    DayOfMonth,
    DayOfYear,
    WeekNumber,
    MonthOfYear,
    MonthName,
    CalendarQuarter,
    CalendarYear,
    IsWeekend,
    FiscalMonth,
    FiscalQuarter,
    FiscalYear
)
SELECT
    (YEAR(c.FullDate) * 10000) + (MONTH(c.FullDate) * 100) + DAY(c.FullDate) AS DateKey,
    c.FullDate,
    c.DayOfWeek,
    CASE c.DayOfWeek
        WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday' WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday'
        ELSE 'Saturday'
    END AS DayName,
    c.DayOfMonth,
    c.DayOfYear,
    c.WeekNumber,
    c.MonthOfYear,
    CASE c.MonthOfYear
        WHEN 1 THEN 'January'  WHEN 2 THEN 'February' WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'    WHEN 5 THEN 'May'      WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'     WHEN 8 THEN 'August'   WHEN 9 THEN 'September'
        WHEN 10 THEN 'October' WHEN 11 THEN 'November' WHEN 12 THEN 'December'
    END AS MonthName,
    c.CalendarQuarter,
    c.CalendarYear,
    CASE WHEN c.DayOfWeek IN (1,7) THEN 1 ELSE 0 END AS IsWeekend,
    MONTH(c.ShiftedFiscalDate)                 AS FiscalMonth,
    DATEPART(QUARTER, c.ShiftedFiscalDate)     AS FiscalQuarter,
    YEAR(c.ShiftedFiscalDate)                  AS FiscalYear
FROM Calc c;

-- 3) Sanity check
DECLARE @Expected int = DATEDIFF(DAY, @StartDate, @EndDate) + 1;
DECLARE @Actual   int = (SELECT COUNT(*) FROM abc_dwh.DimDate);
IF (@Actual <> @Expected)
BEGIN
    RAISERROR('DimDate load mismatch: expected %d rows, got %d.', 16, 1, @Expected, @Actual);
END

COMMIT TRAN;

PRINT CONCAT('DimDate full reload complete. Rows inserted: ', @Actual);
