USE UIC;
GO

SELECT NextReport, COUNT(*) Cnt
FROM dbo.DataFrame
GROUP BY NextReport
ORDER BY Cnt DESC


SELECT ReportCode, COUNT(*) Cnt
FROM dbo.report
GROUP BY ReportCode
ORDER BY Cnt DESC


;WITH cte(InsertUser, TotalUserReports) AS
(
	SELECT Insertuser, COUNT(*) TotalReports
	FROM dbo.report
	GROUP BY InsertUser
)
SELECT *, UserReportCount * 100.0 / TotalUserReports AS Perc
FROM cte
	CROSS APPLY (SELECT r.InsertUser, r.ReportCode, COUNT(*) AS UserReportCount
				FROM dbo.report r
				WHERE r.InsertUser = cte.InsertUser
					AND r.ReportCode IN (SELECT ReportCode
										FROM dbo.report
										GROUP BY ReportCode
										HAVING COUNT(*) < 20)
				GROUP BY r.InsertUser, r.ReportCode) rcnt
ORDER BY cte.InsertUser, rcnt.UserReportCount DESC;

