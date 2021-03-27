SELECT 
	YEAR(ws.created_at) AS Yr,
    MONTH(ws.created_at) AS Mo,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
	ON o.website_session_id = ws.website_session_id
WHERE ws.created_at < '2013-01-01'
GROUP BY
	1,2

SELECT 
	YEAR(ws.created_at) AS Yr,
    WEEK(ws.created_at) AS Wk,
    MIN(DATE(ws.created_at)) AS week_start,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
	ON o.website_session_id = ws.website_session_id
WHERE ws.created_at < '2013-01-01'
GROUP BY
	1,2
    
