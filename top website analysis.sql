-- Website analysis

-- Assignment 1: Finding top website pages 

SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC;

-- Assignment 2: Top Entry Pages

-- Step 1: Find first page view for each session
-- Step 2: Find the url the cust saw on that first pageview
CREATE TEMPORARY TABLE first_pv_per_session
SELECT 
	website_session_id,
    MIN(website_pageview_id) as first_pv
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id
	
SELECT 
	website_pageviews.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_pv_per_session.website_session_id) AS sessions_hitting_page
FROM first_pv_per_session
	LEFT JOIN website_pageviews
		ON first_pv_per_session.first_pv = website_pageviews.website_pageview_id
GROUP BY website_pageviews.pageview_url
        
-- Assignment #3: Bounce Rate Analysis 

-- STEP 1: find the first website_pageview_url for relevant sessions
-- STEP 2: ID the landing page of each session
-- STEP 3: Count the pageviews for each session, to ID "bounces"
-- STEP 4: Summarizing by counting total sessions and bounced sessions

CREATE TEMPORARY TABLE first_pageviews
SELECT 
	website_session_id,
    MIN(website_pageview_id) as min_first_pv
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY 
	website_session_id;

-- bring in landing page but restrict to home only

CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT 
	first_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews.min_first_pv
WHERE website_pageviews.pageview_url = '/home';

SELECT * FROM sessions_w_home_landing_page

-- create a table to have a count of pageviews per session
	-- then limit to just bounced_sessions
    
CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_page_views

FROM sessions_w_home_landing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id

GROUP BY 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page

HAVING
	COUNT(website_pageviews.website_pageview_id) = 1;

-- doing this just to show what is in the query, then will apply a count

SELECT 
	sessions_w_home_landing_page.website_session_id,
    bounced_sessions.website_session_id AS bounced_website_session_id
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY 
	sessions_w_home_landing_page.website_session_id;
    
-- Applying count and rate for bounced sessions

SELECT 
	COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS total_sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS bounce_rate
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id;

-- Assignment #4: Landing page test 

-- Step 0: find when the new page/lander launched 
-- Step 1: finding the first website_pageview_id for relevant session
-- Step 2: IDing the landing page for each session
-- Step 3: count pageviews for each session, to ID "bounces"
-- Step 4: summarize total sessions and bounced sessions by LP 

-- finding the first created_at and first pageview for lander-1

SELECT
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	  AND created_at IS NOT NULL
   
-- first_created_at = '2016-06-09 00:35:45'
-- first_pageview_id = 23504
    
-- finding the website_session_id's and min_pageview_id's for the lander1 page limiting to the date, min_pageview_id, gsearch, and nonbrand

CREATE TEMPORARY TABLE first_lander_pageviews
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at < '2012-07-28' 
        AND website_pageviews.website_pageview_id > 23504 -- the min_pageview_id we found
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 
	website_pageviews.website_session_id;

SELECT * FROM first_lander_pageviews

-- brining in the landing page to each session but just restricting to home and lander1 

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT 
	first_lander_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_lander_pageviews
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_pageview_id = first_lander_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

-- then a table to have count of pageviews per session and limit it to bounced_sessions

CREATE TEMPORARY TABLE nonbrand_test_bounced_session
SELECT 
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed

FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id
        
GROUP BY 
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page

HAVING
	COUNT(count_of_pages_viewed) = 1;
    
-- Do this to show then count after

SELECT 
	nonbrand_test_sessions_w_landing_page.landing_page,
    nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_bounced_session.website_session_id AS bounced_website_session_id
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_session
		ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_session.website_session_id
ORDER BY 
	nonbrand_test_sessions_w_landing_page.website_session_id;

-- USING COUNT to narrow down along with bounce rate

SELECT 
	nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT nonbrand_test_bounced_session.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT nonbrand_test_bounced_session.website_session_id)/COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS bounce_rate
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_session
		ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_session.website_session_id
GROUP BY 
	nonbrand_test_sessions_w_landing_page.landing_page;

-- Assignment #5 Landing page trend analysis 

-- STEP 1: findthe first website_pageview_id for relevant sessions
-- STEP 2: IDing the landing page for each session
-- STEP 3: count pageviews for each session, to ID "bounces"
-- STEP 4: summarize by week (bounce rate, session to each lander)

CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count
SELECT 
	website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews

FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id

WHERE website_sessions.created_at > '2012-06-01' -- by requestor
	  AND website_sessions.created_at < '2012-08-31' -- per assignment
      AND website_sessions.utm_source = 'gsearch'
      AND website_sessions.utm_campaign = 'nonbrand'

GROUP BY 
	website_sessions.website_session_id
    
CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT 
	sessions_w_min_pv_id_and_view_count.website_session_id,
    sessions_w_min_pv_id_and_view_count.first_pageview_id,
    sessions_w_min_pv_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
    
FROM sessions_w_min_pv_id_and_view_count
	LEFT JOIN website_pageviews
		ON sessions_w_min_pv_id_and_view_count.first_pageview_id = website_pageviews.website_pageview_id
    
SELECT 
-- 	YEARWEEK(session_created_at) AS year_week,
    MIN(DATE(session_created_at)) AS week_start_date,
--     COUNT(DISTINCT website_session_id) AS total_sessions,
--     COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
    
FROM sessions_w_counts_lander_and_created_at

GROUP BY 
	YEARWEEK(session_created_at)













