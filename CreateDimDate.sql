-- ==========================================================
-- Dimension Table: DimDate
-- Schema : abc_dwh
-- Purpose: Stores Dates 
-- ==========================================================


-- Drop existing table if needed
IF OBJECT_ID('abc_dwh.DimDate', 'U') IS NOT NULL
    DROP TABLE abc_dwh.DimDate;
GO

-- Create DimDate table
CREATE TABLE abc_dwh.DimDate
(
    DateKey             INT             NOT NULL PRIMARY KEY,       -- e.g. 20251026
    FullDate            DATE            NOT NULL,                   -- Actual date
    DayOfWeek           INT             NOT NULL,                   -- 1=Sunday ... 7=Saturday
    DayName             VARCHAR(20)     NOT NULL,                   -- Monday, Tuesday, etc.
    DayOfMonth          INT             NOT NULL,                   -- 1–31
    DayOfYear           INT             NOT NULL,                   -- 1–366
    WeekNumber          INT             NOT NULL,                   -- Week number in the year
    MonthOfYear         INT             NOT NULL,                   -- 1–12
    MonthName           VARCHAR(20)     NOT NULL,                   -- January, February, etc.
    CalendarQuarter     INT             NOT NULL,                   -- 1–4
    CalendarYear        INT             NOT NULL,                   -- e.g. 2025
    IsWeekend           BIT             NOT NULL DEFAULT 0,         -- 1=Weekend, 0=Weekday
    FiscalMonth         INT             NULL,                       -- Optional fiscal period mapping
    FiscalQuarter       INT             NULL,
    FiscalYear          INT             NULL,
    CreatedDate         DATETIME        DEFAULT GETDATE(),          -- ETL load timestamp
    MsgKey              UNIQUEIDENTIFIER NULL,
	ExportFlag          INT             NULL
);
GO

-- Add useful index for queries by FullDate
CREATE UNIQUE INDEX IX_DimDate_FullDate ON abc_dwh.DimDate(FullDate);
GO
