USE UIC;
GO

IF OBJECT_ID('dbo.dimReportPath','U') IS NOT NULL
	DROP TABLE dbo.dimReportPath;
GO
CREATE TABLE dbo.dimReportPath
(
	ReportPathID INT IDENTITY(1,1) PRIMARY KEY,
	ReportPath VARCHAR(50) NOT NULL
);

INSERT INTO dbo.dimReportPath(ReportPath)
SELECT DISTINCT ReportPath
FROM dbo.Report
ORDER BY ReportPath DESC;


IF OBJECT_ID('dbo.dimReportCode','U') IS NOT NULL
	DROP TABLE dbo.dimReportCode;
GO
CREATE TABLE dbo.dimReportCode
(
	ReportCodeID INT IDENTITY(1,1) PRIMARY KEY,
	ReportCode VARCHAR(100)
);
GO

INSERT INTO dbo.dimReportCode(ReportCode)
SELECT DISTINCT ReportCode
FROM dbo.Report
order BY ReportCode;


IF OBJECT_ID('dbo.dimUser','U') IS NOT NULL
	DROP TABLE dbo.dimUser;
GO
CREATE TABLE dbo.dimUser
(
	UserID INT IDENTITY(1,1) PRIMARY KEY,
	UserName VARCHAR(100)
);
GO

INSERT INTO dbo.dimUser(UserName)
SELECT DISTINCT InsertUser
FROM dbo.Report
ORDER BY InsertUser;

/*Facility Levels*/
IF OBJECT_ID('dbo.dimFacilityLevels','U') IS NOT NULL
	DROP TABLE dbo.dimFacilityLevels;
GO
CREATE TABLE dbo.dimFacilityLevels(
	FacilityLevelsID	TINYINT			PRIMARY KEY		IDENTITY(1,1),
	FacilityLevels		VARCHAR(10)		UNIQUE,
	InsertTimeStamp		DATETIME						DEFAULT(SYSDATETIME()),
	UpdateTimeStamp		DATETIME						DEFAULT(SYSDATETIME()),
	UpdateUser			NVARCHAR(128)					DEFAULT(SYSTEM_USER)
);

INSERT INTO dbo.dimFacilityLevels(FacilityLevels)
SELECT '1'
UNION
SELECT '2'
UNION
SELECT '3'
UNION
SELECT '4'
UNION
SELECT '5'
UNION
SELECT '1,2'
UNION
SELECT '1,3'
UNION
SELECT '1,4'
UNION
SELECT '1,5'
UNION
SELECT '2,3'
UNION
SELECT '2,4'
UNION
SELECT '2,5'
UNION
SELECT '3,4'
UNION
SELECT '3,5'
UNION
SELECT '4,5';


