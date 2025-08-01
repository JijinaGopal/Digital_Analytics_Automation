USE E_Commerce_Project
GO

TRUNCATE TABLE orders;
TRUNCATE TABLE order_items;
TRUNCATE TABLE order_item_refunds;
TRUNCATE TABLE products;
TRUNCATE TABLE website_sessions;
TRUNCATE TABLE website_pageviews;


------------------------------------------------------ DATA LOAD ------------------------
-- 1. Drop existing tables if they exist
DROP TABLE IF EXISTS orders_staging;

-- 2. Create staging table for raw CSV data
CREATE TABLE orders_staging (
    order_id INT,
    created_at varchar(50),
    website_session_id INT,
    user_id INT,
    primary_product_id INT,
    items_purchased INT,
    price_usd FLOAT,
    cogs_usd Float
);



-- 3. Bulk insert into staging table
BULK INSERT orders_staging
FROM 'C:\Users\Administrator\Desktop\Automation\data\orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);



-- 4. Create final clean table
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INT,
    created_at DATETIME,
    website_session_id INT,
    user_id INT,
    primary_product_id INT,
    items_purchased INT,
    price_usd FLOAT,
    cogs_usd FLOAT
);



-- 5. Insert clean records from staging to final table
INSERT INTO orders (
    order_id,
    created_at,
    website_session_id,
    user_id,
    primary_product_id,
    items_purchased,
    price_usd,
    cogs_usd
)
SELECT
    order_id,
    TRY_CONVERT(DATETIME, REPLACE(created_at, '"', ''), 120) AS created_at,
    website_session_id,
    user_id,
    primary_product_id,
    items_purchased,
    price_usd,
    cogs_usd
	FROM orders_staging


--------------------------------------------------------------------------------------------------------------------------------------------

-- Drop if exists
DROP TABLE IF EXISTS order_items_staging;

-- 1. Staging table
CREATE TABLE order_items_staging (
    order_item_id VARCHAR(50),
    created_at VARCHAR(50),
    order_id INT,
    product_id INT,
    is_primary_item INT,
    price_usd FLOAT,
    cogs_usd FLOAT
);


-- 2. Load from CSV
BULK INSERT order_items_staging
FROM 'C:\Users\Administrator\Desktop\Automation\data\order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

-- 3. Create clean final table
DROP TABLE IF EXISTS order_items;

CREATE TABLE order_items (
    order_item_id INT,
    created_at DATETIME,
    order_id INT,
    product_id INT,
    is_primary_item INT,
    price_usd FLOAT,
    cogs_usd FLOAT
);

-- 4. Insert clean data 
INSERT INTO order_items (
    order_item_id,
    created_at,
    order_id,
    product_id,
    is_primary_item,
    price_usd,
    cogs_usd
)
SELECT
    order_item_id,
    TRY_CONVERT(DATETIME, REPLACE(created_at, '"', ''), 120) AS created_at,
    order_id,
    product_id,
    is_primary_item,
    price_usd,
    cogs_usd
FROM order_items_staging


----------------------------------------------------------------------------------------------------------------------------------------
-- 1. Drop staging table if exists
DROP TABLE IF EXISTS order_item_refunds_staging;

-- 2. Create staging table 
CREATE TABLE order_item_refunds_staging (
    order_item_refund_id INT,
    created_at VARCHAR(50),
    order_item_id INT,
    order_id INT,
    refund_amount_usd FLOAT
);

-- 3. Bulk insert from CSV
BULK INSERT order_item_refunds_staging
FROM 'C:\Users\Administrator\Desktop\Automation\data\order_item_refunds.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

-- 4. Drop clean table if exists
DROP TABLE IF EXISTS order_item_refunds;

-- 5. Create clean and typed table
CREATE TABLE order_item_refunds (
    order_item_refund_id INT,
    created_at DATETIME,
    order_item_id INT,
    order_id INT,
    refund_amount_usd FLOAT
);

-- 6. Insert cleaned data with type conversion
INSERT INTO order_item_refunds (
    order_item_refund_id,
    created_at,
    order_item_id,
    order_id,
    refund_amount_usd
)
SELECT
    order_item_refund_id ,
    TRY_CONVERT(DATETIME, REPLACE(created_at, '"', ''), 120) AS created_at,
    order_item_id,
    order_id ,
    refund_amount_usd
FROM order_item_refunds_staging


---------------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Drop if exists
DROP TABLE IF EXISTS products_staging;

-- 2. Create staging table
CREATE TABLE products_staging (
    product_id INT,
    created_at VARCHAR(50),
    product_name VARCHAR(255)
);

-- 3. Bulk insert raw data
BULK INSERT products_staging
FROM 'C:\Users\Administrator\Desktop\Automation\data\products.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

-- 4. Drop final clean table
DROP TABLE IF EXISTS products;

-- 5. Create clean table with correct types
CREATE TABLE products (
    product_id INT,
    created_at DATETIME,
    product_name VARCHAR(255)
);

-- 6. Insert cleaned data
INSERT INTO products (
    product_id,
    created_at,
    product_name
)
SELECT
    product_id,
    TRY_CONVERT(DATETIME, REPLACE(created_at, '"', ''), 120) AS created_at,
    product_name
FROM products_staging



-------------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Drop staging table if it exists
DROP TABLE IF EXISTS website_sessions_staging;

-- 2. Create staging table
CREATE TABLE website_sessions_staging (
    website_session_id INT,
    created_at VARCHAR(50),
    user_id INT,
    is_repeat_session INT,
    utm_source VARCHAR(255),
    utm_campaign VARCHAR(255),
    utm_content VARCHAR(255),
    device_type VARCHAR(100),
    http_referer VARCHAR(255)
);

-- 3. Bulk insert raw CSV data
BULK INSERT website_sessions_staging
FROM 'C:\Users\Administrator\Desktop\Automation\data\website_sessions.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

-- 4. Drop clean table if exists
DROP TABLE IF EXISTS website_sessions;

-- 5. Create clean final table
CREATE TABLE website_sessions (
    website_session_id INT,
    created_at DATETIME,
    user_id INT,
    is_repeat_session INT,
    utm_source VARCHAR(255),
    utm_campaign VARCHAR(255),
    utm_content VARCHAR(255),
    device_type VARCHAR(100),
    http_referer VARCHAR(255)
);

-- 6. Insert cleaned and typed records
INSERT INTO website_sessions (
    website_session_id,
    created_at,
    user_id,
    is_repeat_session,
    utm_source,
    utm_campaign,
    utm_content,
    device_type,
    http_referer
)
SELECT
    website_session_id ,
    TRY_CONVERT(DATETIME, REPLACE(created_at, '"', ''), 120) AS created_at,
    user_id,
    is_repeat_session,
    utm_source,
    utm_campaign,
    utm_content,
    device_type,
    http_referer
FROM website_sessions_staging

-------------------------------------------------------------------------------------------------------------------------------------------------

-- 1. Drop existing staging table if it exists
DROP TABLE IF EXISTS website_pageviews_staging;

-- 2. Create staging table (temporary raw load)
CREATE TABLE website_pageviews_staging (
    website_pageview_id INT,
    created_at VARCHAR(50),
    website_session_id INT,
    pageview_url VARCHAR(255)
);

-- 3. Bulk insert from CSV into staging
BULK INSERT website_pageviews_staging
FROM 'C:\Users\Administrator\Desktop\Automation\data\website_pageviews.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

-- 4. Drop final clean table if it exists
DROP TABLE IF EXISTS website_pageviews;

-- 5. Create clean table with correct data types
CREATE TABLE website_pageviews (
    website_pageview_id INT,
    created_at DATETIME,
    website_session_id INT,
    pageview_url VARCHAR(255)
);

-- 6. Insert cleaned records into final table
INSERT INTO website_pageviews (
    website_pageview_id,
    created_at,
    website_session_id,
    pageview_url
)
SELECT
    website_pageview_id,
    TRY_CONVERT(DATETIME, REPLACE(created_at, '"', ''), 120) AS created_at,
    website_session_id,
    pageview_url
FROM website_pageviews_staging
WHERE
    TRY_CAST(website_pageview_id AS INT) IS NOT NULL AND
    TRY_CONVERT(DATETIME, created_at, 105) IS NOT NULL;


-- ===================================
-- 2. REMOVE DUPLICATES FROM EACH TABLE
-- ===================================

-- Orders
;WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id, created_at, website_session_id, user_id, primary_product_id, items_purchased, price_usd, cogs_usd ORDER BY (SELECT NULL)) AS rn
  FROM orders
)
DELETE FROM cte WHERE rn > 1;

-- Order Items
;WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY order_item_id, created_at, order_id, product_id, is_primary_item, price_usd, cogs_usd ORDER BY (SELECT NULL)) AS rn
  FROM order_items
)
DELETE FROM cte WHERE rn > 1;

-- Order Item Refunds
;WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY order_item_refund_id, created_at, order_item_id, order_id, refund_amount_usd ORDER BY (SELECT NULL)) AS rn
  FROM order_item_refunds
)
DELETE FROM cte WHERE rn > 1;

-- Products
;WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY product_id, created_at, product_name ORDER BY (SELECT NULL)) AS rn
  FROM products
)
DELETE FROM cte WHERE rn > 1;

-- Website Sessions
;WITH cte AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY website_session_id, created_at, user_id, is_repeat_session, utm_source, utm_campaign, utm_content, device_type, http_referer
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM website_sessions
)
DELETE FROM cte WHERE rn > 1;

-- Website Pageviews
;WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY website_pageview_id, created_at, website_session_id, pageview_url ORDER BY (SELECT NULL)) AS rn
  FROM website_pageviews
)
DELETE FROM cte WHERE rn > 1;



-- ===================================
-- 3. HANDLE NULLs / 'NULL' / 'Unknown'
-- ===================================

-- Text: Website Sessions
UPDATE website_sessions SET utm_source = 'Other' WHERE LTRIM(RTRIM(utm_source)) IS NULL OR utm_source IN ('NULL', 'Unknown', '');
UPDATE website_sessions SET utm_campaign = 'Other' WHERE LTRIM(RTRIM(utm_campaign)) IS NULL OR utm_campaign IN ('NULL', 'Unknown', '');
UPDATE website_sessions SET utm_content = 'Other' WHERE LTRIM(RTRIM(utm_content)) IS NULL OR utm_content IN ('NULL', 'Unknown', '');
UPDATE website_sessions SET http_referer = 'Other' WHERE LTRIM(RTRIM(http_referer)) IS NULL OR http_referer IN ('NULL', 'Unknown', '');
UPDATE website_sessions SET device_type = 'Other' WHERE LTRIM(RTRIM(device_type)) IS NULL OR device_type IN ('NULL', 'Unknown', '');

-- Text: Products
UPDATE products SET product_name = 'Other' WHERE LTRIM(RTRIM(product_name)) IS NULL OR product_name IN ('NULL', 'Unknown', '');

-- Text: Website Pageviews
UPDATE website_pageviews SET pageview_url = 'Other' WHERE LTRIM(RTRIM(pageview_url)) IS NULL OR pageview_url IN ('NULL', 'Unknown', '');

-- Text: Orders
UPDATE orders SET primary_product_id = 0 WHERE primary_product_id IS NULL;

-- Replace NULLs in numeric columns
UPDATE orders SET items_purchased = 0 WHERE items_purchased IS NULL;
UPDATE orders SET price_usd = 0 WHERE price_usd IS NULL;
UPDATE orders SET cogs_usd = 0 WHERE cogs_usd IS NULL;

UPDATE order_items SET is_primary_item = 0 WHERE is_primary_item IS NULL;
UPDATE order_items SET price_usd = 0 WHERE price_usd IS NULL;
UPDATE order_items SET cogs_usd = 0 WHERE cogs_usd IS NULL;



UPDATE order_item_refunds SET refund_amount_usd = 0 WHERE refund_amount_usd IS NULL;


  -- 1. Invalid price/cost in orders
IF EXISTS (
    SELECT 1 FROM orders WHERE price_usd <= 0 OR cogs_usd <= 0
)
    PRINT 'Issue Found: Orders with price_usd or cogs_usd <= 0';

-- 2. Invalid price/cost in order_items
IF EXISTS (
    SELECT 1 FROM order_items
    WHERE TRY_CAST(price_usd AS FLOAT) <= 0 OR TRY_CAST(cogs_usd AS FLOAT) <= 0
)
    PRINT 'Issue Found: Order items with price_usd or cogs_usd <= 0';


-- 3. Negative quantity
IF EXISTS (
    SELECT 1 FROM orders WHERE items_purchased < 0
)
    PRINT 'Issue Found: Orders with items_purchased < 0';

-- 4. Refund greater than price
IF EXISTS (
    select * from order_item_refunds as A
join order_items as B
on A.order_item_id = b.order_item_id
where A.refund_amount_usd > b.price_usd
)
    PRINT 'Issue Found: Refund amount exceeds order price';


-- 5. Duplicate sessions with same timestamp
IF EXISTS (
    SELECT website_session_id
    FROM website_sessions
    GROUP BY website_session_id, created_at
    HAVING COUNT(*) > 1
)
    PRINT 'Issue Found: Duplicate session timestamps';

-- 6. Orphan order_id in order_items
IF EXISTS (
    SELECT 1 FROM order_items
    WHERE order_id NOT IN (SELECT order_id FROM orders)
)
    PRINT 'Issue Found: order_id in order_items not found in orders';

-- 7. Orphan order_item_id in refunds
IF EXISTS (
    SELECT 1 FROM order_item_refunds
    WHERE order_item_id NOT IN (SELECT order_item_id FROM order_items)
)
    PRINT 'Issue Found: order_item_id in refunds not found in order_items';


-- 9. Multiple refunds per item
IF EXISTS (
    SELECT order_item_id FROM order_item_refunds
    GROUP BY order_item_id HAVING COUNT(*) > 1
)
    PRINT 'Issue Found: Duplicate refunds for the same item';

-- 10. Pageviews linked to missing session_id
IF EXISTS (
    SELECT 1 FROM website_pageviews
    WHERE website_session_id NOT IN (SELECT website_session_id FROM website_sessions)
)
    PRINT 'Issue Found: Pageviews with missing session IDs';




