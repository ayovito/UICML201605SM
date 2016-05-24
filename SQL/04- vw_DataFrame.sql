USE UIC;
GO

IF OBJECT_ID('dbo.vw_DataFrame', 'V') IS NOT NULL
	DROP VIEW dbo.vw_DataFrame;
GO

CREATE VIEW dbo.vw_DataFrame

AS

SELECT 
	ReportID
	, ReportCodeID
	, UserID
	, ReportYear
	, ReportMonth
	, ReportDay
	, ReportHour
	, ReportMinute
	, ReportCodeID1
	, IsSameDay1
	, IsSameMonth1
	, DaysDelta1
	, HoursDelta1
	, MinutesDelta1
	--, FacilityLevelsID1
	--, FacilityCount1
	--, SubFacilityCount1
	, ReportCodeID2
	, IsSameDay2
	, IsSameMonth2
	, DaysDelta2
	, HoursDelta2
	, MinutesDelta2
	--, FacilityLevelsID2	
	--, FacilityCount2
	--, SubFacilityCount2
	, ReportCodeID3
	, IsSameDay3
	, IsSameMonth3
	, DaysDelta3
	, HoursDelta3
	, MinutesDelta3
	--, FacilityLevelsID3
	--, FacilityCount3
	--, SubFacilityCount3
	, ReportCodeID4
	, IsSameDay4
	, IsSameMonth4
	, DaysDelta4
	, HoursDelta4
	, MinutesDelta4
	--, FacilityLevelsID4
	--, FacilityCount4
	--, SubFacilityCount4
	, ReportCodeID5
	, IsSameDay5
	, IsSameMonth5
	, DaysDelta5
	, HoursDelta5
	, MinutesDelta5
	--, FacilityLevelsID5
	--, FacilityCount5
	--, SubFacilityCount5
	, NextReport
FROM dbo.DataFrame df
	JOIN dbo.dimReportCode rc
		ON rc.ReportCode = df.ReportCode
	JOIN dbo.dimUser u
		ON u.UserName = df.InsertUser
	JOIN dbo.dimReportPath rp
		ON rp.ReportPath = df.ReportPath;

GO


IF OBJECT_ID('dbo.if_Report', 'IF') IS NOT NULL
	DROP FUNCTION dbo.if_Report;
GO
CREATE FUNCTION [dbo].[if_Report]
(
	@user VARCHAR(128)
)
RETURNS TABLE
AS RETURN
	SELECT ReportPath, ReportCode, CAST(InsertTimeStamp AS DATE) AS ReportDate, COUNT(*) AS ReportCount
	FROM dbo.report
	WHERE InsertUser = @user
	GROUP BY ReportPath, ReportCode, CAST(InsertTimeStamp AS DATE)

GO
