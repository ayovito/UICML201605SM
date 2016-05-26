USE UIC;
GO

--Construct final training dataframe
IF OBJECT_ID('tempdb..#reportbase','U') IS NOT NULL
	DROP TABLE #reportbase;
GO
SELECT ReportID, ReportPath, ReportCode, InsertTimeStamp, InsertUser,
	ReportYear, ReportMonth, ReportDay, ReportHour, ReportMinute,
	LAG(ReportID, 1, 0) OVER(PARTITION BY InsertUser ORDER BY InsertTimeStamp, ReportID) AS ReportID1,
	LAG(ReportID, 2, 0) OVER(PARTITION BY InsertUser ORDER BY InsertTimeStamp, ReportID) AS ReportID2,
	LAG(ReportID, 3, 0) OVER(PARTITION BY InsertUser ORDER BY InsertTimeStamp, ReportID) AS ReportID3,
	LAG(ReportID, 4, 0) OVER(PARTITION BY InsertUser ORDER BY InsertTimeStamp, ReportID) AS ReportID4,
	LAG(ReportID, 5, 0) OVER(PARTITION BY InsertUser ORDER BY InsertTimeStamp, ReportID) AS ReportID5,
	LEAD(ReportCode, 1, 0) OVER(PARTITION BY InsertUser ORDER BY InsertTimeStamp, ReportID) AS NextReport
INTO #reportbase
FROM dbo.Report
WHERE ReportCode NOT IN
	(SELECT ReportCode
	FROM dbo.report
	GROUP BY ReportCode
	HAVING COUNT(*) < 20)
ORDER BY InsertUser, InsertTimeStamp, ReportID;

--Create final DataFrame for training data
IF OBJECT_ID('dbo.DataFrame','U') IS NOT NULL
	DROP TABLE dbo.DataFrame;
GO
CREATE TABLE dbo.DataFrame
	(
	ReportID			INT							PRIMARY KEY,
	ReportPath			VARCHAR(50)		NOT NULL,
	ReportCode			VARCHAR(60)		NOT NULL,
	InsertTimeStamp		DATETIME		NOT NULL,
	InsertUser			VARCHAR(50)		NOT NULL,
	ReportYear			SMALLINT		NOT NULL,
	ReportMonth			TINYINT			NOT NULL,
	ReportDay			TINYINT			NOT NULL,
	ReportHour			TINYINT			NOT NULL,
	ReportMinute		TINYINT			NOT NULL,
	ReportCodeID1		INT				NOT NULL,
	IsSameDay1			SMALLINT		NOT NULL,
	IsSameMonth1		SMALLINT		NOT NULL,
	DaysDelta1			INT				NOT NULL,
	HoursDelta1			INT				NOT NULL,
	MinutesDelta1		INT				NOT NULL,
	--FacilityLevelsID1	TINYINT			NOT NULL,
	--FacilityCount1		SMALLINT		NOT NULL,
	--SubFacilityCount1	SMALLINT		NOT NULL,
	ReportCodeID2		INT				NOT NULL,
	IsSameDay2			SMALLINT		NOT NULL,
	IsSameMonth2		SMALLINT		NOT NULL,
	DaysDelta2			INT				NOT NULL,
	HoursDelta2			INT				NOT NULL,
	MinutesDelta2		INT				NOT NULL,
	--FacilityLevelsID2	TINYINT			NOT NULL,
	--FacilityCount2		SMALLINT		NOT NULL,
	--SubFacilityCount2	SMALLINT		NOT NULL,
	ReportCodeID3		INT				NOT NULL,
	IsSameDay3			SMALLINT		NOT NULL,
	IsSameMonth3		SMALLINT		NOT NULL,
	DaysDelta3			INT				NOT NULL,
	HoursDelta3			INT				NOT NULL,
	MinutesDelta3		INT				NOT NULL,
	--FacilityLevelsID3	TINYINT			NOT NULL,
	--FacilityCount3		SMALLINT		NOT NULL,
	--SubFacilityCount3	SMALLINT		NOT NULL,
	ReportCodeID4		INT				NOT NULL,
	IsSameDay4			SMALLINT		NOT NULL,
	IsSameMonth4		SMALLINT		NOT NULL,
	DaysDelta4			INT				NOT NULL,
	HoursDelta4			INT				NOT NULL,
	MinutesDelta4		INT				NOT NULL,
	--FacilityLevelsID4	TINYINT			NOT NULL,
	--FacilityCount4		SMALLINT		NOT NULL,
	--SubFacilityCount4	SMALLINT		NOT NULL,
	ReportCodeID5		INT				NOT NULL,
	IsSameDay5			SMALLINT		NOT NULL,
	IsSameMonth5		SMALLINT		NOT NULL,
	DaysDelta5			INT				NOT NULL,
	HoursDelta5			INT				NOT NULL,
	MinutesDelta5		INT				NOT NULL,
	--FacilityLevelsID5	TINYINT			NOT NULL,
	--FacilityCount5		SMALLINT		NOT NULL,
	--SubFacilityCount5	SMALLINT		NOT NULL,
	NextReport			VARCHAR(60)		NOT NULL
	);

--Get time lag between current report and reports1-5
--Features to extract: IsSameDay1-5, IsSameMonth1-5, DaysDelta1-5, HoursDelta1-5, MinutesDelta1-5
INSERT INTO dbo.DataFrame
SELECT r.ReportID, r.ReportPath, r.ReportCode, r.InsertTimeStamp, r.InsertUser,
	r.ReportYear, r.ReportMonth, r.ReportDay, r.ReportHour, r.ReportMinute,
	
	ISNULL(drc1.ReportCodeID, -1) AS ReportCodeID1,
	CASE WHEN r1.InsertTimeStamp IS NULL THEN -1 WHEN CAST(r1.InsertTimeStamp AS DATE) = CAST(r.InsertTimeStamp AS DATE) THEN 1 ELSE 0 END IsSameDay1,
	CASE WHEN r1.InsertTimeStamp IS NULL THEN -1 WHEN YEAR(r1.InsertTimeStamp) = YEAR(r.InsertTimeStamp) 
		AND MONTH(r1.InsertTimeStamp) = MONTH(r.InsertTimeStamp) THEN 1 ELSE 0 END AS IsSameMonth1,
	ISNULL(DATEDIFF(dd, r1.InsertTimeStamp, r.InsertTimeStamp),-1) AS DaysDelta1,
	ISNULL(DATEDIFF(hh, r1.InsertTimeStamp, r.InsertTimeStamp), -1) AS HoursDelta1,
	ISNULL(DATEDIFF(mi, r1.InsertTimeStamp, r.InsertTimeStamp), -1) AS MinutesDelta1,
	--ISNULL(r1.FacilityLevelsID, 0) AS FacilityLevelsID1,
	--ISNULL(r1.FacilityCount, -1) AS FacilityCount1, ISNULL(r1.SubFacilityCount, -1) AS SubFacilityCount1,
	
	ISNULL(drc2.ReportCodeID, -1) AS ReportCodeID2,
	CASE WHEN r2.InsertTimeStamp IS NULL THEN -1 WHEN CAST(r2.InsertTimeStamp AS DATE) = CAST(r.InsertTimeStamp AS DATE) THEN 1 ELSE 0 END IsSameDay2,
	CASE WHEN r2.InsertTimeStamp IS NULL THEN -1 WHEN YEAR(r2.InsertTimeStamp) = YEAR(r.InsertTimeStamp) 
		AND MONTH(r2.InsertTimeStamp) = MONTH(r.InsertTimeStamp) THEN 1 ELSE 0 END AS IsSameMonth2,
	ISNULL(DATEDIFF(dd, r2.InsertTimeStamp, r.InsertTimeStamp), -1) AS DaysDelta2,
	ISNULL(DATEDIFF(hh, r2.InsertTimeStamp, r.InsertTimeStamp), -1) AS HoursDelta2,
	ISNULL(DATEDIFF(mi, r2.InsertTimeStamp, r.InsertTimeStamp), -1) AS MinutesDelta2,
	--ISNULL(r2.FacilityLevelsID, 0) AS FacilityLevelsID2,
	--ISNULL(r2.FacilityCount, -1) AS FacilityCount2, ISNULL(r2.SubFacilityCount, -1) AS SubFacilityCount2,
	
	ISNULL(drc3.ReportCodeID, -1) AS ReportCodeID3,
	CASE WHEN r3.InsertTimeStamp IS NULL THEN -1 WHEN CAST(r3.InsertTimeStamp AS DATE) = CAST(r.InsertTimeStamp AS DATE) THEN 1 ELSE 0 END IsSameDay3,
	CASE WHEN r3.InsertTimeStamp IS NULL THEN -1 WHEN YEAR(r3.InsertTimeStamp) = YEAR(r.InsertTimeStamp) 
		AND MONTH(r3.InsertTimeStamp) = MONTH(r.InsertTimeStamp) THEN 1 ELSE 0 END AS IsSameMonth3,
	ISNULL(DATEDIFF(dd, r3.InsertTimeStamp, r.InsertTimeStamp), -1) AS DaysDelta3,
	ISNULL(DATEDIFF(hh, r3.InsertTimeStamp, r.InsertTimeStamp), -1) AS HoursDelta3,
	ISNULL(DATEDIFF(mi, r3.InsertTimeStamp, r.InsertTimeStamp), -1) AS MinutesDelta3,
	--ISNULL(r3.FacilityLevelsID, 0) AS FacilityLevelsID3,
	--ISNULL(r3.FacilityCount, -1) AS FacilityCount3, ISNULL(r3.SubFacilityCount, -1) AS SubFacilityCount3,
		
	ISNULL(drc4.ReportCodeID, -1) AS ReportCodeID4,
	CASE WHEN r4.InsertTimeStamp IS NULL THEN -1 WHEN CAST(r4.InsertTimeStamp AS DATE) = CAST(r.InsertTimeStamp AS DATE) THEN 1 ELSE 0 END IsSameDay4,
	CASE WHEN r4.InsertTimeStamp IS NULL THEN -1 WHEN YEAR(r4.InsertTimeStamp) = YEAR(r.InsertTimeStamp) 
		AND MONTH(r4.InsertTimeStamp) = MONTH(r.InsertTimeStamp) THEN 1 ELSE 0 END AS IsSameMonth4,
	ISNULL(DATEDIFF(dd, r4.InsertTimeStamp, r.InsertTimeStamp), -1) AS DaysDelta4,
	ISNULL(DATEDIFF(hh, r4.InsertTimeStamp, r.InsertTimeStamp), -1) AS HoursDelta4,
	ISNULL(DATEDIFF(mi, r4.InsertTimeStamp, r.InsertTimeStamp), -1) AS MinutesDelta4,
	--ISNULL(r4.FacilityLevelsID, 0) AS FacilityLevelsID4,
	--ISNULL(r4.FacilityCount, -1) AS FacilityCount4, ISNULL(r4.SubFacilityCount, -1) AS SubFacilityCount4,
	
	ISNULL(drc5.ReportCodeID, -1) AS ReportCodeID5,
	CASE WHEN r5.InsertTimeStamp IS NULL THEN -1 WHEN CAST(r5.InsertTimeStamp AS DATE) = CAST(r.InsertTimeStamp AS DATE) THEN 1 ELSE 0 END IsSameDay5,
	CASE WHEN r5.InsertTimeStamp IS NULL THEN -1 WHEN YEAR(r5.InsertTimeStamp) = YEAR(r.InsertTimeStamp) 
		AND MONTH(r5.InsertTimeStamp) = MONTH(r.InsertTimeStamp) THEN 1 ELSE 0 END AS IsSameMonth5,
	ISNULL(DATEDIFF(dd, r5.InsertTimeStamp, r.InsertTimeStamp), -1) AS DaysDelta5,
	ISNULL(DATEDIFF(hh, r5.InsertTimeStamp, r.InsertTimeStamp), -1) AS HoursDelta5,
	ISNULL(DATEDIFF(mi, r5.InsertTimeStamp, r.InsertTimeStamp), -1) AS MinutesDelta5,
	--ISNULL(r5.FacilityLevelsID, 0) AS FacilityLevelsID5,
	--ISNULL(r5.FacilityCount, -1) AS FacilityCount5, ISNULL(r5.SubFacilityCount, -1) AS SubFacilityCount5,
	
	NextReport
	
FROM #reportbase r
	LEFT JOIN dbo.Report r1
		ON r1.ReportID = r.ReportID1
	LEFT JOIN dbo.dimReportCode drc1
		ON drc1.ReportCode = r1.ReportCode
	LEFT JOIN dbo.Report r2
		ON r2.ReportID = r.ReportID2
	LEFT JOIN dbo.dimReportCode drc2
		ON drc2.ReportCode = r2.ReportCode
	LEFT JOIN dbo.Report r3
		ON r3.ReportID = r.ReportID3
	LEFT JOIN dbo.dimReportCode drc3
		ON drc3.ReportCode = r3.ReportCode
	LEFT JOIN dbo.Report r4
		ON r4.ReportID = r.ReportID4
	LEFT JOIN dbo.dimReportCode drc4
		ON drc4.ReportCode = r4.ReportCode
	LEFT JOIN dbo.Report r5
		ON r5.ReportID = r.ReportID5
	LEFT JOIN dbo.dimReportCode drc5
		ON drc5.ReportCode = r5.ReportCode

WHERE NextReport <> '0';

		