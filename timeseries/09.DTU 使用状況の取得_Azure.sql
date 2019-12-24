﻿SELECT TOP 1
	GETDATE() AS counter_date,
	* ,
	(SELECT Max(v)FROM (VALUES 
	(avg_cpu_percent), 
	(avg_data_io_percent), 
	(avg_log_write_percent), 
	(xtp_storage_percent), 
	(max_worker_percent), 
	(max_session_percent)) 
	AS value(v)) as [max_DTU_percent] 
FROM 
	sys.dm_db_resource_stats WITH(NOLOCK)
ORDER BY 
	end_time DESC
OPTION (RECOMPILE, MAXDOP 1);