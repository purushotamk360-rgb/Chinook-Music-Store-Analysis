# 🎵 Chinook-Music-Store-Analysis - SQL Business Analysis
Analyzed a relational database of 11 tables, 3,500+ tracks, and customers across 24 countries to uncover sales and customer behavior insights.

## 📌 Project Overview

This project analyzes the **Chinook Digital Music Store database** using **MySQL** to understand sales performance, customer purchasing behavior, product performance, geographic markets, customer churn, and customer value.

The project was completed as part of the **Newton School SQL Project** and follows a complete data-analysis workflow — from understanding the database and checking data quality to writing advanced SQL queries and converting query results into business insights.

---

## 🎯 Project Objective

The main objective of this project is to analyze Chinook's music sales data and answer important business questions related to:

- Customer behavior and purchasing patterns
- Sales and revenue performance
- Top-performing tracks, artists, albums, and genres
- Geographic market performance
- Customer segmentation and churn
- Customer lifetime value
- Product affinity and cross-selling opportunities
- Regional customer purchasing behavior

The analysis aims to convert raw relational data into **actionable business insights** that can support strategic decision-making.

---

## 🗄️ Database Overview

The Chinook database is a relational music-store database containing:

- **11 tables**
- **3,500+ music tracks**
- **59 customers**
- Customers across **24 countries**
- Sales transaction and invoice data
- Artist, album, genre, playlist, and employee information

### Main Tables

| Table | Description |
|---|---|
| `customer` | Customer information and geographic details |
| `employee` | Employee and support representative information |
| `invoice` | Customer purchase/invoice information |
| `invoice_line` | Individual products purchased in each invoice |
| `track` | Music track information |
| `album` | Album information |
| `artist` | Artist information |
| `genre` | Music genre information |
| `media_type` | Track media type information |
| `playlist` | Playlist information |
| `playlist_track` | Relationship between playlists and tracks |

---

## 🔍 Project Workflow

The project was completed through the following analytical workflow:

### 1. Database Exploration
- Explored the Chinook database structure
- Identified tables and relationships
- Examined available columns and data types
- Reviewed primary and foreign-key relationships

### 2. Data Quality Analysis
- Checked important columns for missing values
- Checked customer email uniqueness
- Checked duplicate invoice-line combinations
- Checked duplicate track names within albums
- Identified areas where duplicate or NULL values require careful handling

### 3. Exploratory Data Analysis
Analyzed:
- Customer distribution
- Revenue by geographic location
- Invoice volume
- Customer purchasing frequency
- Average order value
- Tracks purchased
- Customer tenure

### 4. Customer Analysis
Performed:
- Customer revenue ranking
- Top customers by country
- Customer purchasing behavior analysis
- Customer churn analysis
- Customer risk profiling
- Customer Lifetime Value (CLV) analysis

### 5. Product & Sales Analysis
Analyzed:
- Top-selling tracks
- Top artists
- Genre performance
- Album performance
- USA genre sales
- Product affinity
- Tracks purchased by individual customers

### 6. Business Analysis
Translated SQL outputs into:
- Key insights
- Business opportunities
- Customer-retention strategies
- Marketing recommendations
- Regional growth opportunities

---

# 📊 Key Analysis Performed

## Objective Questions

The project answers objective questions covering:

1. Missing values and duplicate records
2. Top-selling tracks and artists in the USA
3. Customer demographic/geographic distribution
4. Revenue and invoice performance by country, state, and city
5. Top 5 customers by revenue in each country
6. Top-selling track for each customer
7. Customer purchasing behavior patterns
8. Customer churn rate
9. Genre sales contribution in the USA
10. Customers purchasing tracks from at least three genres
11. Genre ranking based on USA sales performance
12. Identification of inactive/churned customers

---

# 💼 Subjective Business Analysis

The project also contains deeper business-focused analysis.

### 1. Album Promotion Analysis
Identified high-performing albums and artists in the USA to determine products that could be prioritized for advertising and promotion.

### 2. International Genre Analysis
Compared top-selling genres across countries outside the USA to identify common patterns and regional differences.

### 3. Customer Tenure Analysis
Compared purchasing behavior between:
- New customers
- Mid-term customers
- Long-term customers

Metrics included:
- Average spending
- Average order value
- Purchase frequency
- Customer tenure

### 4. Product Affinity Analysis
Identified genre combinations that are frequently purchased together to understand potential cross-selling opportunities.

### 5. Regional Market Analysis
Compared countries using:
- Customer count
- Revenue
- Invoice volume
- Average order value
- Customer churn

### 6. Customer Risk Profiling
Created customer risk tiers based on purchase inactivity:

- Low Risk
- Medium Risk
- High Risk
- Churned
- Never Purchased

### 7. Customer Lifetime Value Modeling
Created a historical CLV proxy using:
- Total revenue
- Number of invoices
- Customer tenure
- Estimated annual customer value

### 8. Promotional Campaign Impact Framework
Since the Chinook database does not contain campaign exposure, discount, or campaign-cost information, a framework was developed for measuring campaign impact using:
- Customer acquisition
- Conversion
- Revenue
- Retention
- Control groups / A-B testing

### 9. Independent Analytical Approach
Developed an exploratory-data-analysis approach for situations where business questions are not predefined.

### 10. Database Modification
Used `ALTER TABLE` to add a new `release_year` column to the `album` table.

### 11. Geographic Purchasing Behavior
Compared countries based on:
- Number of customers
- Average amount spent
- Average tracks purchased per customer

---

# 🧠 Key Insights

Some of the major insights identified during the analysis include:

- The **USA is the largest revenue-generating market**, followed by several strong markets in Canada and Europe.
- Customer revenue is concentrated among a smaller group of high-value customers.
- **František Wichterlová** was identified as the highest-spending customer in the analyzed customer-level results.
- Customer purchase frequency and total customer value are not always directly proportional.
- Rock and Metal are prominent among the top-selling tracks in the USA analysis.
- **AC/DC** appears prominently among the top-performing artists in the USA.
- Customers show different purchasing patterns based on geographic location and customer tenure.
- Product affinity analysis can reveal opportunities for cross-selling between genres.
- Customer inactivity can be used to identify potential churn-risk segments.
- Long-term customers with consistent purchasing behavior can represent important sources of customer lifetime value.

---

# 📈 Key KPIs Analyzed

The project focused on several customer and sales KPIs, including:

| KPI | Purpose |
|---|---|
| Total Revenue | Measure overall sales performance |
| Average Order Value | Measure average customer transaction value |
| Average Invoices per Customer | Measure purchase frequency |
| Average Tracks per Order | Measure basket size |
| Average Customer Tenure | Measure customer relationship duration |
| Customer Churn Rate | Measure customer retention risk |
| Total Tracks Sold | Measure product demand |
| Revenue by Country | Measure geographic performance |
| Revenue by Genre | Measure product-category performance |

---

# 🛠️ SQL Skills Used

This project strengthened practical SQL skills including:

- `SELECT`
- `WHERE`
- `GROUP BY`
- `HAVING`
- `ORDER BY`
- `JOIN`
- `LEFT JOIN`
- `INNER JOIN`
- `UNION ALL`
- `CASE`
- `COALESCE`
- Aggregate functions
  - `COUNT()`
  - `SUM()`
  - `AVG()`
  - `MIN()`
  - `MAX()`
- String functions
  - `CONCAT()`
- Date functions
  - `DATE()`
  - `DATE_FORMAT()`
  - `DATEDIFF()`
  - `DATE_SUB()`
- CTEs using `WITH`
- Window functions
  - `RANK()`
  - `LAG()`
  - `OVER()`
  - `PARTITION BY`
- Subqueries
- `ALTER TABLE`

---

# 📂 Repository Structure

```text
📁 Chinook-Music-Store-SQL-Business-Analysis
│
├── 📄 README.md
├── 📄 chinook_queries.sql
├── 📄 Chinook_Report.docx
└── 📄 Chinook_PPT.pptx
