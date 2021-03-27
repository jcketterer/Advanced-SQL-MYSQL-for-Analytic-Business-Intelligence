SELECT 
	website_session_id,
    created_at,
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) as day -- 0 = Monday, 1 = Tuesday
FROM website_sessions
WHERE website_session_id BETWEEN 150000 AND 155000 