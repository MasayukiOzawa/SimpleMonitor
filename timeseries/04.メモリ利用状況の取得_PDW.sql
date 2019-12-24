﻿SET NOCOUNT ON;

SELECT
	GETDATE() AS counter_date,
	p.pdw_node_id,
	type,
	RTRIM(p.object_name) AS object_name,
	RTRIM(p.counter_name) AS counter_name,
	RTRIM(p.instance_name) AS instance_name,
	p.cntr_value 
FROM 
	sys.dm_pdw_nodes_os_performance_counters p WITH(NOLOCK)
	LEFT JOIN
	sys.dm_pdw_nodes n WITH(NOLOCK)
	ON
	n.pdw_node_id = p.pdw_node_id
WHERE
	p.object_name LIKE '%Memory Manager%'
OPTION(RECOMPILE, MAXDOP 1);