/*
This script deletes objects from the ML schema in the Analysis database.
Delete is limited to:
	Views, Inline Table Valued Functions, Synonyms, Procedures, and Tables.
Delete does not take into account foreign keys, there is none at inception.
*/
SET NOCOUNT ON;

USE UIC;
GO

--IF	SQL_INLINE_TABLE_VALUED_FUNCTION
--P 	SQL_STORED_PROCEDURE
--SN	SYNONYM
--U 	USER_TABLE
--V 	VIEW

IF OBJECT_ID('tempdb..#mlobjects','U') IS NOT NULL
	DROP TABLE #mlobjects;
GO
SELECT s.name + '.' + o.name AS ObjectName, o.[type] AS ObjectType, o.type_desc,
	CASE o.[type] WHEN 'IF' THEN 'DROP FUNCTION ' + s.name + '.' + o.name
		WHEN 'P' THEN 'DROP PROC ' + s.name + '.' + o.name
		WHEN 'SN' THEN 'DROP SYNONYM ' + s.name + '.' + o.name
		WHEN 'U' THEN 'DROP TABLE ' + s.name + '.' + o.name
		WHEN 'V' THEN 'DROP VIEW ' + s.name + '.' + o.name
		ELSE 'DROP OBJECT ' + s.name + '.' + o.name END AS SQLDrop,
	CAST(0 AS BIT) AS Executed
INTO #mlobjects
FROM sys.objects o
	JOIN sys.schemas s
		ON s.schema_id = o.schema_id
WHERE s.name = 'dbo'
	AND o.[type] IN ('IF','P','SN','U','V');
	
PRINT 'Deleting ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' objects...';

DECLARE @sql NVARCHAR(1000),
		@objectname NVARCHAR(128);

WHILE EXISTS(SELECT ObjectName FROM #mlobjects WHERE Executed = 0)
BEGIN
	SELECT TOP 1 @objectname = ObjectName, @sql = SQLDrop
	FROM #mlobjects
	WHERE Executed = 0;

	EXEC sp_executesql @sql;

	UPDATE #mlobjects
	SET Executed = 1
	WHERE ObjectName = @objectname;

	PRINT @objectname + N' has been deleted';
END
