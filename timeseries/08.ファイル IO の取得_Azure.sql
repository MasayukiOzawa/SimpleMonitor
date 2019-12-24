﻿SET NOCOUNT ON;

/*
-- ファイル I/O の取得
DROP TABLE IF EXISTS #T1
DROP TABLE IF EXISTS #T2
*/
SELECT 
	GETDATE() AS counter_date,
	[database_files].[name], 
	[database_files].[type_desc],
	[database_files].[size] * 8.0 AS size_KB,  
	[database_files].[max_size] * 8.0 AS max_size_KB,  
	[database_files].[growth],
	CASE [is_percent_growth]
		WHEN 0 THEN [database_files].[growth] * 8.0 
		ELSE [growth]
	END AS [converted_growth],
	[database_files].[is_percent_growth],
	[fn_virtualfilestats].[NumberReads], 
	[fn_virtualfilestats].[IoStallReadMS], 
	[fn_virtualfilestats].[BytesRead],  
	[fn_virtualfilestats].[NumberWrites],  
	[fn_virtualfilestats].[IoStallWriteMS], 
	[fn_virtualfilestats].[BytesWritten],  
	[fn_virtualfilestats].[BytesOnDisk] 
INTO #T1
FROM 
	fn_virtualfilestats(DB_ID(), NULL) 
	LEFT JOIN
	sys.database_files WITH(NOLOCK)
	ON
	database_files.file_id  = fn_virtualfilestats.FileId
OPTION(RECOMPILE, MAXDOP 1);

WAITFOR DELAY '00:00:03';

SELECT 
	GETDATE() AS counter_date,
	[database_files].[name], 
	[database_files].[type_desc],
	[database_files].[size] * 8.0 AS size_KB,  
	[database_files].[max_size] * 8.0 AS max_size_KB,  
	[database_files].[growth],
	CASE [is_percent_growth]
		WHEN 0 THEN [database_files].[growth] * 8.0 
		ELSE [growth]
	END AS [converted_growth],
	[database_files].[is_percent_growth],
	[fn_virtualfilestats].[NumberReads], 
	[fn_virtualfilestats].[IoStallReadMS], 
	[fn_virtualfilestats].[BytesRead],  
	[fn_virtualfilestats].[NumberWrites],  
	[fn_virtualfilestats].[IoStallWriteMS], 
	[fn_virtualfilestats].[BytesWritten],  
	[fn_virtualfilestats].[BytesOnDisk] 
INTO #T2
FROM 
	fn_virtualfilestats(DB_ID(), NULL) 
	LEFT JOIN
	sys.database_files WITH(NOLOCK)
	ON
	database_files.file_id  = fn_virtualfilestats.FileId
OPTION(RECOMPILE, MAXDOP 1);

SELECT
	#T2.counter_date,
	#T2.name,
	CAST((#T2.NumberReads - #T1.NumberReads) / (DATEDIFF(ms, #T1.counter_date, #T2.counter_date) / 1000.0) AS bigint) AS NumberReads,
	CAST((#T2.BytesRead - #T1.BytesRead) / (DATEDIFF(ms, #T1.counter_date, #T2.counter_date) / 1000.0) AS bigint) AS BytesRead,
	CAST((#T2.IoStallReadMS - #T1.IoStallReadMS) / (DATEDIFF(ms, #T1.counter_date, #T2.counter_date) / 1000.0) AS bigint) AS IoStallReadMS,
	CAST((#T2.NumberWrites - #T1.NumberWrites) / (DATEDIFF(ms, #T1.counter_date, #T2.counter_date) / 1000.0) AS bigint) AS NumberWrites,
	CAST((#T2.BytesWritten - #T1.BytesWritten) / (DATEDIFF(ms, #T1.counter_date, #T2.counter_date) / 1000.0) AS bigint) AS BytesWritten,
	CAST((#T2.IoStallWriteMS - #T1.IoStallWriteMS) / (DATEDIFF(ms, #T1.counter_date, #T2.counter_date) / 1000.0) AS bigint) AS IoStallWriteMS
FROM
	#T1
	LEFT JOIN
	#T2
	ON
	#T1.name = #T2.name
OPTION(RECOMPILE, MAXDOP 1);
