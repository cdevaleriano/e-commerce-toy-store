-- SETUP OF TABLES
CREATE TABLE orders (
	order_id INTEGER PRIMARY KEY,
	created_at TIMESTAMP,
	website_session_id INTEGER,
	user_id INTEGER,
	primary_product_id INTEGER,
	items_purchased INTEGER,
	price_usd FLOAT,
	cogs FLOAT
);

CREATE TABLE order_items (
	order_item_id INTEGER PRIMARY KEY,
	created_at TIMESTAMP,
	order_id INTEGER REFERENCES orders (order_id),
	product_id INTEGER, 
	is_primary_item	INTEGER,
	price_usd FLOAT,
	cogs_usd FLOAT
);

CREATE TABLE order_item_refunds (
	order_item_refund_id INTEGER PRIMARY KEY,
	created_at TIMESTAMP,
	order_item_id INTEGER REFERENCES order_items (order_item_id),
	order_id INTEGER REFERENCES orders (order_id),
	refund_amount_usd FLOAT
);

CREATE TABLE products (
	product_id INTEGER PRIMARY KEY,
	created_at TIMESTAMP,
	product_name VARCHAR
);

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

-- QUESTIONS

-- What is the trend in website sessions and order volume?
--- Monthly to Include Seasonality

-- What is the session-to-order conversion rate?


-- YEARLY
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

-- MONTHLY
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

-- In the yar 2015, we have a conversion rate of 8.44 % which is an increase from the previous year showing the improvements

-- Which marketing channels have been most successful?
--- Group By Landing Pages

-- How has the revenue per order evolved?
--- 

-- How has the revenue per session evolved?


