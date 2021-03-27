SELECT 
	hr,
    ROUND(AVG(CASE WHEN wkday = 0 THEN website_sessions ELSE NULL END),1) AS Mon,
    ROUND(AVG(CASE WHEN wkday = 1 THEN website_sessions ELSE NULL END),1) AS Tues,
    ROUND(AVG(CASE WHEN wkday = 2 THEN website_sessions ELSE NULL END),1) AS Wed,
    ROUND(AVG(CASE WHEN wkday = 3 THEN website_sessions ELSE NULL END),1) AS Thurs,
    ROUND(AVG(CASE WHEN wkday = 4 THEN website_sessions ELSE NULL END),1) AS Fri,
    ROUND(AVG(CASE WHEN wkday = 5 THEN website_sessions ELSE NULL END),1) AS Sat,
    ROUND(AVG(CASE WHEN wkday = 6 THEN website_sessions ELSE NULL END),1) AS Sun
FROM (
SELECT
	DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS wkday,
	HOUR(created_at) AS Hr,
    COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3
) AS daily_hourly_sessions
GROUP BY 1
ORDER BY 1