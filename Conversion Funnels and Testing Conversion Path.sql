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
    
    
    