-- Building Conversion Funnels 

-- build a mini conversion funnel, from /lander-2 to /cart
-- want to know how many people reach each step, also drop off rate
-- only looking at /lander-2 traffic
-- only looking at custs who like Mr Fuzzy only

-- Step 1: select all pageviews for relevant sessions 
-- Step 2: ID each relevant pageview as the specific funnel step
-- Step 3: create the session-level conversion funnel
-- Step 4: aggregate the data to assess funnel permformance 

-- first show all pageviews we care about
-- then remove the comments from the flag columns one by one to show difference

SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_create_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
	  AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at;

-- next put the previous query into a subquery 
-- group by website_session_id, then take the MAX() of each the flags
-- the MAX() then becomes a made_it flag for that session, to show the session made it there

SELECT 
	website_session_id,
    MAX(products_page) AS products_madeit,
    MAX(mrfuzzy_page) AS mrfuzzy_madeit,
    MAX(cart_page) AS cart_madeit

FROM(

	SELECT 
		website_sessions.website_session_id,
		website_pageviews.pageview_url,
		website_pageviews.created_at AS pageview_create_at,
		CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
		CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
		CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
	FROM website_sessions
		LEFT JOIN website_pageviews
			ON website_sessions.website_session_id = website_pageviews.website_session_id
	WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
		  AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
	ORDER BY 
		website_sessions.website_session_id,
		website_pageviews.created_at
        
) AS pageview_level

GROUP BY 
	website_session_id

-- next turn this previous query into a temp table 

CREATE TEMPORARY TABLE session_level_madeit_flags
SELECT 
	website_session_id,
    MAX(products_page) AS products_madeit,
    MAX(mrfuzzy_page) AS mrfuzzy_madeit,
    MAX(cart_page) AS cart_madeit

FROM(

	SELECT 
		website_sessions.website_session_id,
		website_pageviews.pageview_url,
		website_pageviews.created_at AS pageview_create_at,
		CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
		CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
		CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
	FROM website_sessions
		LEFT JOIN website_pageviews
			ON website_sessions.website_session_id = website_pageviews.website_session_id
	WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
		  AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
	ORDER BY 
		website_sessions.website_session_id,
		website_pageviews.created_at
        
) AS pageview_level

GROUP BY 
	website_session_id;

-- then produce final output

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN products_madeit = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_madeit = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_madeit = 1 THEN website_session_id ELSE NULL END) AS to_cart
FROM session_level_madeit_flags

-- then translate those oucnts to click rates for part 2 of final output using the above query

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN products_madeit = 1 THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT website_session_id)AS click_to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_madeit = 1 THEN website_session_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN products_madeit = 1 THEN website_session_id ELSE NULL END) AS click_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_madeit = 1 THEN website_session_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN mrfuzzy_madeit = 1 THEN website_session_id ELSE NULL END) AS click_to_cart
FROM session_level_madeit_flags

-- Building Conversion Funnels 

-- STEP 1: select all pageviews for relevant sessions 
-- STEP 2: ID each pageview as the specific funnel step
-- STEP 3: create the session-level conversion funnel view 
-- STEP 4: Aggregate the data to assess funnel performance 

SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    -- website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at > '2012-08-05'
    AND website_sessions.created_at < '2012-09-05'
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at;
    
-- Wrap the above query into a subquery 

SELECT 
	website_session_id,
    MAX(products_page) AS product_madeit,
	MAX(mrfuzzy_page) AS mrfuzzy_madeit,
	MAX(cart_page) AS cart_madeit,
    MAX(shipping_page) AS shipping_madeit,
    MAX(billing_page) AS billing_madeit,
    MAX(thankyou_page) AS thankyou_madeit
FROM(
	SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    -- website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at > '2012-08-05'
    AND website_sessions.created_at < '2012-09-05'
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY
	website_session_id;

-- Create a temp table
CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT 
	website_session_id,
    MAX(products_page) AS product_madeit,
	MAX(mrfuzzy_page) AS mrfuzzy_madeit,
	MAX(cart_page) AS cart_madeit,
    MAX(shipping_page) AS shipping_madeit,
    MAX(billing_page) AS billing_madeit,
    MAX(thankyou_page) AS thankyou_madeit
FROM(
	SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    -- website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at > '2012-08-05'
    AND website_sessions.created_at < '2012-09-05'
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY
	website_session_id;

SELECT * FROM session_level_made_it_flags

-- Final output 1 

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions, 
    COUNT(DISTINCT CASE WHEN product_madeit = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_madeit = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_madeit = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_madeit = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_madeit = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_madeit = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flags;

-- final output 2 click rates

SELECT 
	COUNT(DISTINCT CASE WHEN product_madeit = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_click_rt, 
    COUNT(DISTINCT CASE WHEN mrfuzzy_madeit = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product_madeit = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_madeit = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_madeit = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_madeit = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_madeit = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_madeit = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_madeit = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_madeit = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_madeit = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flags;
        
--  Analysing Conversion funnels 

-- first finding the start point to frame the analysis 

SELECT 
	MIN(website_pageviews.website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2';
-- first_pv_id = 53550

-- looking at this ID w/o orders, the add in orders later 

SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
	orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550 -- first pageview ID in previous query
	AND website_pageviews.created_at < '2012-11-10' -- time of assignment 
    AND website_pageviews.pageview_url IN ('/billing','/billing-2');

-- wrap into a subquery and summarize

SELECT 
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) as orders, 
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS billing_to_order_rt
FROM (
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
	orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550 -- first pageview ID in previous query
	AND website_pageviews.created_at < '2012-11-10' -- time of assignment 
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS billing_sessions_w_orders
GROUP BY 
	billing_version_seen




    
    