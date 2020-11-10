-- Understanding the tables

SELECT * FROM website_sessions 
WHERE website_session_id = 1059;

SELECT * FROM website_pageviews
WHERE website_session_id = 1059;

SELECT * FROM orders
WHERE website_session_id = 1059;

SELECT 
	website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt    
FROM website_sessions 
	LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id

WHERE website_sessions.website_session_id BETWEEN 1000 and 2000

GROUP BY 1
ORDER BY 2 DESC;

-- Assignment: Top Traffic Sources

SELECT 
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS num_of_sessions
FROM website_sessions
WHERE created_at < '2012-04-12' 
GROUP BY 
	utm_source,
    utm_campaign,
    http_referer
ORDER BY num_of_sessions DESC;

-- Assignement Traffic Source Conversion Rate Analysis 

SELECT 
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt    
FROM website_sessions 
	LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14' 
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'

-- Date Functions

SELECT 
    WEEK(created_at),
    YEAR(created_at),
    MIN(DATE(created_at)) AS week_start,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 and 115000 
GROUP BY 1,2

-- Case Pivoting and Bid Optimization & Trend Analysis 

SELECT 
    primary_product_id,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS orders_w_1_item,
    COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS orders_w_2_item,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1

-- Traffic Source Trending

SELECT 
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions  
FROM website_sessions
WHERE created_at < '2012-05-10'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
    WEEK(created_at)
    
-- Bid Optimization for Paid Traffice     
    
SELECT
	website_sessions.device_type,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt    
FROM website_sessions 
	LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	device_type

-- Trending w/ Granular Segments

SELECT 
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-04-15' AND '2012-06-09'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	WEEK(created_at)
	








