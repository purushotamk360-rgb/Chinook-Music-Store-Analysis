-- ============================================================
-- Chinook Project — SQL Analysis
-- Name    : Purushotam Kumar
-- Date    : 18 - 08 - 2026
-- ============================================================

-- ============================================================
--  CHINOOK PROJECT — OBJECTIVE QUESTIONS (Q1 to Q12)
--  Database: chinook 
-- ============================================================

USE chinook;

-- ============================================================
-- Q1. Does any table have missing values or duplicates?
-- ============================================================

-- (a) Check NULL counts in key columns of each table
SELECT 
    'customer' AS tbl,
    COUNT(*) AS total_rows,
    SUM(company IS NULL) AS null_company,
    SUM(state IS NULL) AS null_state,
    SUM(postal_code IS NULL) AS null_postal_code,
    SUM(phone IS NULL) AS null_phone,
    SUM(fax IS NULL) AS null_fax
FROM
    customer 
UNION ALL SELECT 
    'invoice',
    COUNT(*),
    SUM(billing_state IS NULL),
    SUM(billing_postal_code IS NULL),
    NULL,
    NULL,
    NULL
FROM
    invoice 
UNION ALL SELECT 
    'track',
    COUNT(*),
    SUM(album_id IS NULL),
    SUM(genre_id IS NULL),
    SUM(composer IS NULL),
    SUM(bytes IS NULL),
    NULL
FROM
    track 
UNION ALL SELECT 
    'employee',
    COUNT(*),
    SUM(reports_to IS NULL),
    SUM(state IS NULL),
    SUM(postal_code IS NULL),
    SUM(phone IS NULL),
    SUM(fax IS NULL)
FROM
    employee;

-- (b) Check for duplicate customer emails (should be unique)
SELECT 
    email, COUNT(*) AS cnt
FROM
    customer
GROUP BY email
HAVING cnt > 1;

-- (c) Check for duplicate invoice_line entries
SELECT 
    invoice_id, track_id, COUNT(*) AS cnt
FROM
    invoice_line
GROUP BY invoice_id , track_id
HAVING cnt > 1;

-- (d) Check for duplicate tracks by name + album
SELECT 
    name, album_id, COUNT(*) AS cnt
FROM
    track
GROUP BY name , album_id
HAVING cnt > 1;

-- ============================================================
-- Q2. Top-selling tracks and top artist in the USA and identify their most famous genres
-- ============================================================

SELECT 
    t.name AS track_name,
    ar.name AS artist_name,
    g.name AS genre,
    SUM(il.quantity) AS total_units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue
FROM
    invoice_line il
        JOIN
    invoice i ON il.invoice_id = i.invoice_id
        JOIN
    track t ON il.track_id = t.track_id
        JOIN
    album al ON t.album_id = al.album_id
        JOIN
    artist ar ON al.artist_id = ar.artist_id
        JOIN
    genre g ON t.genre_id = g.genre_id
WHERE
    i.billing_country = 'USA'
GROUP BY t.track_id , t.name , ar.name , g.name
ORDER BY total_units_sold DESC , total_revenue DESC
LIMIT 10;

-- ============================================================
-- Q3. Customer demographic breakdown (location)
-- ============================================================
-- Since the Chinook dataset does not have age or gender columns, we can only do location-based demographic breakdown. 
SELECT 
    c.country,
    c.state,
    c.city,
    COUNT(c.customer_id) AS total_customers,
    ROUND(SUM(i.total), 2) AS total_revenue,
    ROUND(AVG(i.total), 2) AS avg_spend_per_invoice,
    COUNT(i.invoice_id) AS total_invoices
FROM
    customer c
        LEFT JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.country , c.state , c.city
ORDER BY total_customers DESC , total_revenue DESC;

-- ============================================================
-- Q4. Calculate the total revenue and number of invoices for each country, state, and city:
-- ============================================================

SELECT 
    billing_country AS country,
    COALESCE(billing_state, 'N/A') AS state,
    billing_city AS city,
    COUNT(invoice_id) AS num_invoices,
    ROUND(SUM(total), 2) AS total_revenue
FROM
    invoice
GROUP BY billing_country , billing_state , billing_city
ORDER BY total_revenue DESC;

-- ============================================================
-- Q5. Find the top 5 customers by total revenue in each country
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.country,
        ROUND(SUM(i.total), 2)                 AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, customer_name, c.country
),
ranked AS (
    SELECT
        customer_id,
        customer_name,
        country,
        total_spent,
        RANK() OVER (PARTITION BY country ORDER BY total_spent DESC) AS rnk
    FROM customer_revenue
)
SELECT
    country,
    rnk          AS rank_in_country,
    customer_name,
    total_spent
FROM ranked
WHERE rnk <= 5
ORDER BY country, rnk;

-- ============================================================
-- Q6. Identify the top-selling track for each customer
-- ============================================================

WITH track_per_customer AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        t.name                                  AS track_name,
        SUM(il.quantity)                        AS times_purchased,
        RANK() OVER (
            PARTITION BY c.customer_id
            ORDER BY SUM(il.quantity) DESC
        ) AS rnk
    FROM customer c
    JOIN invoice      i  ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id  = il.invoice_id
    JOIN track        t  ON il.track_id   = t.track_id
    GROUP BY c.customer_id, customer_name, t.track_id, t.name
)
SELECT
    customer_id,
    customer_name,
    track_name,
    times_purchased
FROM track_per_customer
WHERE rnk = 1
ORDER BY customer_id;

-- ============================================================
-- Q7. Are there any patterns or trends in customer purchasing behavior 
-- (e.g., frequency of purchases, preferred payment methods, average order value)?
-- ============================================================

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    COUNT(DISTINCT i.invoice_id) AS purchase_frequency,
    ROUND(SUM(i.total), 2) AS total_spent,
    ROUND(AVG(i.total), 2) AS avg_order_value,
    SUM(il.quantity) AS total_tracks_bought,
    ROUND(SUM(il.quantity) / COUNT(DISTINCT i.invoice_id),
            2) AS avg_tracks_per_order,
    MIN(DATE(i.invoice_date)) AS first_purchase,
    MAX(DATE(i.invoice_date)) AS last_purchase,
    DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS days_as_customer
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY c.customer_id , customer_name , c.country
ORDER BY total_spent DESC;

-- ============================================================
-- Q8. What is the customer churn rate?
-- ============================================================

WITH customer_activity AS (
    SELECT
        c.customer_id,
        MAX(i.invoice_date)                      AS last_purchase_date,
        CASE
            WHEN MAX(i.invoice_date) < DATE_SUB(
                (SELECT MAX(invoice_date) FROM invoice),
                 INTERVAL 3 MONTH)
            OR MAX(i.invoice_date) IS NULL
            THEN 'Churned'
            ELSE 'Active'
        END                                      AS customer_status
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
)
SELECT
    COUNT(*)                                     AS total_customers,
    SUM(customer_status = 'Churned')             AS churned_customers,
    SUM(customer_status = 'Active')              AS active_customers,
    ROUND(
        SUM(customer_status = 'Churned') * 100.0
        / COUNT(*), 2)                           AS churn_rate_pct
FROM customer_activity;

-- ============================================================
-- Q9. Calculate the percentage of total sales contributed by each genre in the USA and identify the best-selling genres and artists.
-- ============================================================

SELECT
    g.name                                          AS genre,
    ar.name                                         AS top_artist,
    COUNT(DISTINCT il.invoice_line_id)              AS total_tracks_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)      AS genre_revenue,
    ROUND(
        SUM(il.unit_price * il.quantity) * 100.0
        / SUM(SUM(il.unit_price * il.quantity)) 
          OVER(), 2)                                AS pct_of_total_usa_sales,
    RANK() OVER(
        ORDER BY SUM(il.unit_price * il.quantity) 
        DESC)                                       AS genre_rank
FROM invoice_line il
JOIN invoice  i  ON il.invoice_id  = i.invoice_id
JOIN track    t  ON il.track_id    = t.track_id
JOIN genre    g  ON t.genre_id     = g.genre_id
JOIN album    al ON t.album_id     = al.album_id
JOIN artist   ar ON al.artist_id   = ar.artist_id
WHERE i.billing_country = 'USA'
GROUP BY g.genre_id, g.name, ar.artist_id, ar.name
ORDER BY genre_rank, genre_revenue DESC;

-- ============================================================
-- Q10. Find customers who have purchased tracks from at least 3 different genres
-- ============================================================

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    COUNT(DISTINCT t.genre_id) AS distinct_genres_purchased
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
        JOIN
    track t ON il.track_id = t.track_id
GROUP BY c.customer_id , customer_name , c.country
HAVING distinct_genres_purchased >= 3
ORDER BY distinct_genres_purchased DESC;


-- ============================================================
-- Q11. Rank genres based on their sales performance in the USA
-- ============================================================

SELECT
    g.name                                    AS genre,
    SUM(il.quantity)                          AS total_units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(il.unit_price * il.quantity) DESC
    )                                         AS revenue_rank
FROM invoice_line il
JOIN invoice  i  ON il.invoice_id = i.invoice_id
JOIN track    t  ON il.track_id   = t.track_id
JOIN genre    g  ON t.genre_id    = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.genre_id, g.name
ORDER BY revenue_rank;


-- ============================================================
-- Q12. Identify customers who have not made a purchase in the last 3 months
-- ============================================================

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.country,
    MAX(i.invoice_date) AS last_purchase_date
FROM
    customer c
        LEFT JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id , customer_name , c.email , c.country
HAVING last_purchase_date < (SELECT 
        DATE_SUB(MAX(invoice_date),
                INTERVAL 3 MONTH)
    FROM
        invoice)
    OR last_purchase_date IS NULL
ORDER BY last_purchase_date;

-- ============================================================
-- CHINOOK PROJECT — SUBJECTIVE QUESTIONS (Q1 to Q12)
-- ============================================================

-- ============================================================
-- Q1. Recommend the three albums from the new record label that should be 
-- prioritised for advertising and promotion in the USA based on genre sales analysis.
-- ============================================================
SELECT 
    al.title AS album,
    ar.name AS artist,
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM
    invoice_line il
        JOIN
    invoice i ON il.invoice_id = i.invoice_id
        JOIN
    track t ON il.track_id = t.track_id
        JOIN
    album al ON t.album_id = al.album_id
        JOIN
    artist ar ON al.artist_id = ar.artist_id
        JOIN
    genre g ON t.genre_id = g.genre_id
WHERE
    i.billing_country = 'USA'
GROUP BY al.album_id , al.title , ar.name , g.name
ORDER BY revenue DESC
LIMIT 5;

-- ============================================================
-- Q2. Determine the top-selling genres in countries other than the USA and identify 
-- any commonalities or differences.
-- ============================================================

SELECT i.billing_country AS country, g.name AS genre,
       ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue,
       RANK() OVER (PARTITION BY i.billing_country
                   ORDER BY SUM(il.unit_price * il.quantity) DESC) AS rnk
FROM invoice_line il
JOIN invoice i  ON il.invoice_id = i.invoice_id
JOIN track t    ON il.track_id   = t.track_id
JOIN genre g    ON t.genre_id    = g.genre_id
WHERE i.billing_country <> 'USA'
GROUP BY i.billing_country, g.genre_id, g.name
ORDER BY country, rnk;

-- ============================================================
-- Q3. Long-term vs New Customer Purchasing Behavior
-- ============================================================

WITH customer_tenure AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
        c.country,
        MIN(i.invoice_date)                      AS first_purchase,
        MAX(i.invoice_date)                      AS last_purchase,
        DATEDIFF(
            MAX(i.invoice_date),
            MIN(i.invoice_date))                 AS tenure_days,
        COUNT(DISTINCT i.invoice_id)             AS total_invoices,
        ROUND(SUM(i.total), 2)                   AS total_spent,
        ROUND(AVG(i.total), 2)                   AS avg_order_value
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, customer_name, c.country
),
segmented AS (
    SELECT
        customer_id,
        customer_name,
        country,
        tenure_days,
        total_invoices,
        total_spent,
        avg_order_value,
        first_purchase,
        last_purchase,
        CASE
            WHEN tenure_days > 730 THEN 'Long-Term Customer'
            WHEN tenure_days < 365 THEN 'New Customer'
            ELSE 'Mid-Term Customer'
        END                                      AS customer_segment
    FROM customer_tenure
)
SELECT
    customer_segment,
    COUNT(customer_id)                           AS num_customers,
    ROUND(AVG(total_spent), 2)                   AS avg_total_spent,
    ROUND(AVG(avg_order_value), 2)               AS avg_order_value,
    ROUND(AVG(total_invoices), 2)                AS avg_invoices_per_customer,
    ROUND(AVG(tenure_days), 0)                   AS avg_tenure_days
FROM segmented
GROUP BY customer_segment
ORDER BY avg_total_spent DESC;

-- ============================================================
-- Q4. Product Affinity Analysis
-- ============================================================
USE chinook;
SELECT 
    g1.name AS genre_1,
    g2.name AS genre_2,
    COUNT(*) AS times_bought_together
FROM
    invoice_line il1
        JOIN
    invoice_line il2 ON il1.invoice_id = il2.invoice_id
        AND il1.track_id < il2.track_id
        JOIN
    track t1 ON il1.track_id = t1.track_id
        JOIN
    track t2 ON il2.track_id = t2.track_id
        JOIN
    genre g1 ON t1.genre_id = g1.genre_id
        JOIN
    genre g2 ON t2.genre_id = g2.genre_id
WHERE
    g1.name <> g2.name
GROUP BY g1.name , g2.name
ORDER BY times_bought_together DESC
LIMIT 10;

-- ============================================================
-- Q5. Regional Market Analysis
-- ============================================================

WITH country_stats AS (
    SELECT
        c.country,
        c.customer_id,
        MAX(i.invoice_date)                      AS last_purchase_date
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.country, c.customer_id
)
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id)                AS total_customers,
    ROUND(AVG(i.total), 2)                       AS avg_order_value,
    ROUND(SUM(i.total), 2)                       AS total_revenue,
    COUNT(DISTINCT i.invoice_id)                 AS total_invoices,
    MAX(DATE(i.invoice_date))                    AS latest_purchase,
    SUM(CASE
        WHEN cs.last_purchase_date < DATE_SUB(
            (SELECT MAX(invoice_date) FROM invoice),
             INTERVAL 3 MONTH)
        THEN 1 ELSE 0
    END)                                         AS churned_customers
FROM customer c
JOIN invoice i  ON c.customer_id = i.customer_id
JOIN country_stats cs ON c.customer_id = cs.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;

-- ============================================================
-- Q6. Customer risk profiling based on inactivity
-- ============================================================

WITH last_purchase AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
        c.country,
        c.email,
        MAX(i.invoice_date)                      AS last_purchase_date,
        ROUND(SUM(i.total), 2)                   AS total_spent,
        COUNT(i.invoice_id)                      AS total_invoices,
        DATEDIFF(
            (SELECT MAX(invoice_date) FROM invoice),
             MAX(i.invoice_date))                AS days_inactive
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, customer_name, c.country, c.email
)
SELECT
    customer_id,
    customer_name,
    country,
    email,
    last_purchase_date,
    total_spent,
    total_invoices,
    days_inactive,
    CASE
        WHEN days_inactive IS NULL        THEN 'Never Purchased'
        WHEN days_inactive <= 60          THEN 'Low Risk'
        WHEN days_inactive <= 90          THEN 'Medium Risk'
        WHEN days_inactive <= 180         THEN 'High Risk'
        ELSE                                   'Churned'
    END                                         AS risk_tier
FROM last_purchase
ORDER BY days_inactive DESC;

-- ============================================================
-- Q7. Customer Lifetime Value Modeling
-- ============================================================
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    ROUND(SUM(i.total), 2) AS total_revenue,
    COUNT(DISTINCT i.invoice_id) AS total_invoices,
    DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS tenure_days,
    ROUND(SUM(i.total) / NULLIF(DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)),
                    0) * 365,
            2) AS est_annual_value
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id , customer_name , c.country
ORDER BY est_annual_value DESC;

-- ============================================================
-- Q8. Monthly revenue trend to simulate campaign impact analysis
-- ============================================================

SELECT
    DATE_FORMAT(invoice_date, '%Y-%m')          AS month,
    COUNT(invoice_id)                           AS num_invoices,
    COUNT(DISTINCT customer_id)                 AS unique_customers,
    ROUND(SUM(total), 2)                        AS monthly_revenue,
    ROUND(AVG(total), 2)                        AS avg_order_value,
    ROUND(SUM(total) - LAG(SUM(total))
        OVER (ORDER BY DATE_FORMAT(
            invoice_date, '%Y-%m')), 2)         AS revenue_change_vs_prev_month
FROM invoice
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY month;



-- ============================================================
-- Q10. How can you alter the "Albums" table to add a new column named "ReleaseYear" of type INTEGER to store 
-- the release year of each album?
-- ============================================================
USE chinook;
ALTER TABLE album
ADD COLUMN release_year INT;
DESCRIBE album;

-- ============================================================
-- Q11. Chinook is interested in understanding the purchasing behavior of customers based on their geographical 
-- location. They want to know the average total amount spent by customers from each country, along with the 
-- number of customers and the average number of tracks purchased per customer. 
-- Write an SQL query to provide this information.
-- ============================================================

SELECT 
    c.country,
    COUNT(DISTINCT c.customer_id) AS num_customers,
    ROUND(AVG(i.total), 2) AS avg_amount_spent,
    ROUND(SUM(il.quantity) / COUNT(DISTINCT c.customer_id),
            2) AS avg_tracks_per_customer
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY c.country
ORDER BY num_customers DESC;
