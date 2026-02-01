-- SETUP OF TABLES
CREATE TABLE website_sessions (
	website_session_id INTEGER PRIMARY KEY,
	created_at TIMESTAMP,
	user_id INTEGER,
	is_repeat_session BOOLEAN,
	utm_source VARCHAR,
	utm_campaign VARCHAR,
	utm_content VARCHAR,
	device_type VARCHAR,
	http_referer VARCHAR
);

CREATE TABLE website_pageviews (
	website_pageview_id	INTEGER PRIMARY KEY,
	created_at TIMESTAMP,
	website_session_id INTEGER REFERENCES website_sessions (website_session_id),
	pageview_url VARCHAR
);

-- QUERIES
-- QUERY 1: YEARLY
SELECT
	completed_sessions.year,
	completed_sessions.no_completed,
	all_sessions.no_sessions,
	ROUND(completed_sessions.no_completed * 1.0 / all_sessions.no_sessions * 100, 2) AS conversion_rate
FROM(
	SELECT 
		EXTRACT(YEAR FROM created_at) AS year, 
		COUNT(DISTINCT(website_session_id)) AS no_completed
	FROM website_pageviews
	WHERE pageview_url = '/thank-you-for-your-order'
	GROUP BY year) AS completed_sessions
INNER JOIN (
	SELECT 
		EXTRACT(YEAR FROM created_at) AS year, 
		COUNT(DISTINCT(website_session_id)) AS no_sessions
	FROM website_pageviews
	GROUP BY year
) AS all_sessions
ON completed_sessions.year = all_sessions.year
ORDER BY year DESC;

-- QUERY 2: MONTHLY
WITH completed_sessions AS(
	SELECT 
		EXTRACT(MONTH FROM created_at) AS month,
		EXTRACT(YEAR FROM created_at) AS year, 
		COUNT(DISTINCT(website_session_id)) AS no_completed
	FROM website_pageviews
	WHERE pageview_url = '/thank-you-for-your-order'
	GROUP BY year, month),
	all_sessions AS(
	SELECT 
		EXTRACT(MONTH FROM created_at) AS month,
		EXTRACT(YEAR FROM created_at) AS year, 
		COUNT(DISTINCT(website_session_id)) AS no_sessions
	FROM website_pageviews
	GROUP BY year, month
	)

SELECT
	completed_sessions.month,
	completed_sessions.year,
	ROUND(completed_sessions.no_completed * 1.0 / all_sessions.no_sessions * 100, 2) AS conversion_rate,
	LAG(ROUND(completed_sessions.no_completed * 1.0 / all_sessions.no_sessions * 100, 2), 12) OVER (ORDER BY completed_sessions.year, completed_sessions.month) AS last_year_conversion_rate,
	ROUND((ROUND(completed_sessions.no_completed * 1.0 / all_sessions.no_sessions * 100, 2) - (LAG(ROUND(completed_sessions.no_completed * 1.0 / all_sessions.no_sessions * 100, 2), 12) OVER (ORDER BY completed_sessions.year, completed_sessions.month)))/(LAG(ROUND(completed_sessions.no_completed * 1.0 / all_sessions.no_sessions * 100, 2), 12) OVER (ORDER BY completed_sessions.year, completed_sessions.month)) * 100, 2) AS yoy_change
FROM completed_sessions
INNER JOIN all_sessions
ON completed_sessions.year = all_sessions.year
	AND completed_sessions.month = all_sessions.month
ORDER BY year DESC, month DESC;

-- QUERY 3: BY DEVICE TYPE
SELECT
	completed_sessions.device_type,
	completed_sessions.no_completed,
	all_sessions.no_sessions,
	ROUND(completed_sessions.no_completed * 1.0 / all_sessions.no_sessions * 100, 2) AS conversion_rate
FROM(
	SELECT 
		device_type, 
		COUNT(DISTINCT(website_session_id)) AS no_completed
	FROM website_pageviews
	INNER JOIN website_sessions USING(website_session_id)
	WHERE pageview_url = '/thank-you-for-your-order'
	GROUP BY device_type) AS completed_sessions
INNER JOIN (
	SELECT 
		device_type, 
		COUNT(DISTINCT(website_session_id)) AS no_sessions
	FROM website_pageviews
	INNER JOIN website_sessions USING(website_session_id)
	GROUP BY device_type
) AS all_sessions
ON completed_sessions.device_type = all_sessions.device_type
ORDER BY device_type;

-- QUERY 4: BY UTM CONTENT VARIANT
SELECT
	completed_sessions.utm_content,
	completed_sessions.no_completed,
	all_sessions.no_sessions,
	ROUND(completed_sessions.no_completed * 1.0 / all_sessions.no_sessions * 100, 2) AS conversion_rate
FROM(
	SELECT 
		utm_content, 
		COUNT(DISTINCT(website_session_id)) AS no_completed
	FROM website_pageviews
	INNER JOIN website_sessions USING(website_session_id)
	WHERE pageview_url = '/thank-you-for-your-order' AND NOT utm_content = 'NULL'
	GROUP BY utm_content) AS completed_sessions
INNER JOIN (
	SELECT 
		utm_content, 
		COUNT(DISTINCT(website_session_id)) AS no_sessions
	FROM website_pageviews
	INNER JOIN website_sessions USING(website_session_id)
	WHERE NOT utm_content = 'NULL'
	GROUP BY utm_content
) AS all_sessions
ON completed_sessions.utm_content = all_sessions.utm_content
ORDER BY conversion_rate DESC;

-- How has the revenue per session evolved?


