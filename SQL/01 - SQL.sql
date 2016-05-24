USE UIC;
GO

UPDATE dbo.Report
SET ReportServer = REPLACE(ReportServer, 'DS.SJHS.COM', 'DOMAIN.COM')
WHERE ReportServer LIKE '%DS.SJHS.COM%';

ALTER TABLE dbo.Report
	ALTER COLUMN ReportID INT NOT NULL;
GO

SELECT DISTINCT ReportPath FROM dbo.Report
SELECT DISTINCT ReportCode FROM dbo.Report
SELECT DISTINCT InsertTimeStamp FROM dbo.Report
SELECT DISTINCT InsertUser FROM dbo.Report


--Add NOT NULL constraint on ReportID for PK
ALTER TABLE dbo.Report
	ALTER COLUMN ReportID INT NOT NULL;
GO

--Create Primary Key Clustered Index on ReportID
ALTER TABLE dbo.Report
	ADD CONSTRAINT pk_Report_ReportID PRIMARY KEY(ReportID);
GO


-- Feature extraction --

/*Extract year*/
ALTER TABLE dbo.Report
	ALTER COLUMN InsertTimeStamp DATETIME;

--Create index on InsertUser / InsertTimeStamp
IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_Report_InsertUser_InsertTimeStamp')
	DROP INDEX ix_Report_InsertUser_InsertTimeStamp ON dbo.Report;
GO

ALTER TABLE dbo.Report
	ADD ReportYear SMALLINT;
GO

UPDATE dbo.Report
SET ReportYear = YEAR(InsertTimeStamp)
WHERE ISNULL(ReportYear, 0) <> YEAR(InsertTimeStamp);


/*Extract month*/
ALTER TABLE dbo.Report
	ADD ReportMonth TINYINT;
GO

UPDATE dbo.Report
SET ReportMonth = MONTH(InsertTimeStamp)
WHERE ISNULL(ReportMonth, 0) <> MONTH(InsertTimeStamp);


/*Extract day*/
ALTER TABLE dbo.Report
	ADD ReportDay TINYINT;
GO

UPDATE dbo.Report
SET ReportDay = DAY(InsertTimeStamp)
WHERE ISNULL(ReportDay, 0) <> DAY(InsertTimeStamp);


/*Extract hour*/
ALTER TABLE dbo.Report
	ADD ReportHour TINYINT;
GO

UPDATE dbo.Report
SET ReportHour = DATEPART(HOUR, InsertTimeStamp)
WHERE ISNULL(25, ReportHour) <> DATEPART(HOUR, InsertTimeStamp);


/*Extract minute*/
ALTER TABLE dbo.Report
	ADD ReportMinute TINYINT;
GO

UPDATE dbo.Report
SET ReportMinute = DATEPART(MINUTE, InsertTimeStamp)
WHERE ISNULL(ReportMinute, 61) <> DATEPART(MINUTE, InsertTimeStamp);

