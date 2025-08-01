USE E_Commerce_Project;

-- ---------------------- 1. website_sessions ----------------------
---clear table
TRUNCATE TABLE website_sessions;

---change datatype to varchar
ALTER TABLE website_sessions ALTER COLUMN created_at VARCHAR(50);

---insert the data
BULK INSERT website_sessions
FROM 'C:\Users\Administrator\Desktop\Automation\data\website_sessions.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP'
);

---delete duplicates
WITH cte AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY website_session_id, created_at, user_id, is_repeat_session, utm_source, utm_campaign, utm_content, device_type, http_referer
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM website_sessions
)
DELETE FROM cte WHERE rn > 1;

-- Fix common NULLs or blanks before changing type
UPDATE website_sessions
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;


---change datatype to datetime
ALTER TABLE website_sessions ALTER COLUMN created_at DATETIME;

-- Clean other fields
UPDATE website_sessions
SET utm_source = ISNULL(utm_source, 'unknown'),
    utm_campaign = ISNULL(utm_campaign, 'unknown'),
    utm_content = ISNULL(utm_content, 'unknown'),
    device_type = ISNULL(device_type, 'unknown'),
    http_referer = ISNULL(http_referer, 'unknown');

-- clear the table
TRUNCATE TABLE w_sessions;

-- Copy cleaned data to w_sessions
INSERT INTO w_sessions
SELECT *
FROM website_sessions;


-- ---------------------- 2. website_pageviews ----------------------
---clear table
TRUNCATE TABLE website_pageviews;

---change datatype to varchar
ALTER TABLE website_pageviews ALTER COLUMN created_at VARCHAR(50);

---insert the data
BULK INSERT website_pageviews
FROM 'C:\Users\Administrator\Desktop\Automation\data\website_pageviews.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP'
);

---delete duplicates
WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY website_pageview_id, created_at, website_session_id, pageview_url ORDER BY (SELECT NULL)) AS rn
  FROM website_pageviews
)
DELETE FROM cte WHERE rn > 1

-- Fix common NULLs or blanks before changing type
UPDATE website_pageviews
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

---change datatype to datetime
ALTER TABLE website_pageviews ALTER COLUMN created_at DATETIME;


-- ---------------------- 3. orders ----------------------
---clear table
TRUNCATE TABLE orders;

---change datatype to varchar
ALTER TABLE orders ALTER COLUMN created_at VARCHAR(50);


---change datatype to decimal
ALTER TABLE orders
ALTER COLUMN cogs_usd DECIMAL(10, 2);

---insert the data
BULK INSERT orders
FROM 'C:\Users\Administrator\Desktop\Automation\data\orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP'
);

---delete duplicates
WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id, created_at, website_session_id, user_id, primary_product_id, items_purchased, price_usd, cogs_usd ORDER BY (SELECT NULL)) AS rn
  FROM orders
)
DELETE FROM cte WHERE rn > 1

---Invalid price/cost in orders
IF EXISTS (
    SELECT 1 FROM orders WHERE price_usd <= 0 OR cogs_usd <= 0
)
    PRINT 'Invalid'

---Negative quantity
IF EXISTS (
    SELECT 1 FROM orders WHERE items_purchased < 0
)
    PRINT 'Invalid'

-- Fix common NULLs or blanks before changing type
UPDATE orders
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

---change datatype to datetime
ALTER TABLE orders ALTER COLUMN created_at DATETIME;


-- ---------------------- 4. order_items ----------------------
---remove the data
TRUNCATE TABLE order_items;

---change datatype to varchar
ALTER TABLE order_items ALTER COLUMN created_at VARCHAR(50)

---change datatype to decimal
ALTER TABLE order_items
ALTER COLUMN cogs_usd DECIMAL(10, 2);


---Insert the data
BULK INSERT order_items
FROM 'C:\Users\Administrator\Desktop\Automation\data\order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP'
);

---Delete duplicates
WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY order_item_id, created_at, order_id, product_id, is_primary_item, price_usd, cogs_usd ORDER BY (SELECT NULL)) AS rn
  FROM order_items
)
DELETE FROM cte WHERE rn > 1

---replace null
UPDATE order_items SET is_primary_item = 0 WHERE is_primary_item IS NULL;
UPDATE order_items SET price_usd = 0 WHERE price_usd IS NULL;
UPDATE order_items SET cogs_usd = 0 WHERE cogs_usd IS NULL


---Invalid price/cost in order_items
IF EXISTS (
   SELECT 1 FROM order_items WHERE price_usd <= 0 OR cogs_usd <= 0
)
   PRINT 'Invalid'


---Orphan order_id in order_items
IF EXISTS (
    SELECT 1 FROM order_items
    WHERE order_id NOT IN (SELECT order_id FROM orders)
)
    PRINT 'Invalid'

-- Fix common NULLs or blanks before changing type
UPDATE order_items
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

---change datatype to datetime
ALTER TABLE order_items ALTER COLUMN created_at DATETIME

-- ---------------------- 5. order_item_refunds ----------------------
---remove the data
TRUNCATE TABLE order_item_refunds;

---change datatype to varchar
ALTER TABLE order_item_refunds ALTER COLUMN created_at VARCHAR(50)

---Insert the data
BULK INSERT order_item_refunds
FROM 'C:\Users\Administrator\Desktop\Automation\data\order_item_refunds.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP'
);


---Delete duplicates
WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY order_item_refund_id, created_at, order_item_id, order_id, refund_amount_usd ORDER BY (SELECT NULL)) AS rn
  FROM order_item_refunds
)
DELETE FROM cte WHERE rn > 1


---replace null
UPDATE order_item_refunds SET refund_amount_usd = 0 WHERE refund_amount_usd IS NULL


---compare price and refund amount
IF EXISTS (
    select * from order_item_refunds as A
    join order_items as B
    on A.order_item_id = b.order_item_id
    where A.refund_amount_usd > b.price_usd
)
    PRINT 'Invalid'

---compare orderid
IF EXISTS (
    SELECT 1 FROM order_item_refunds
    WHERE order_item_id NOT IN (SELECT order_item_id FROM order_items)
)
    PRINT 'Invalid'


---Multiple refunds per item
IF EXISTS (
    SELECT order_item_id FROM order_item_refunds
    GROUP BY order_item_id HAVING COUNT(*) > 1
)
    PRINT 'Invalid'

-- Fix common NULLs or blanks before changing type
UPDATE order_item_refunds
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

---change datatype to datetime
ALTER TABLE order_item_refunds ALTER COLUMN created_at DATETIME


-- ---------------------- 6. products ----------------------
---remove the data
TRUNCATE TABLE products;

---change datatype to varchar
ALTER TABLE products ALTER COLUMN created_at VARCHAR(50)

---Insert the data
BULK INSERT products
FROM 'C:\Users\Administrator\Desktop\Automation\data\products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP'
);


---Delete duplicates
WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY product_id, created_at, product_name ORDER BY (SELECT NULL)) AS rn
  FROM products
)
DELETE FROM cte WHERE rn > 1;


----replace null with others
UPDATE products SET product_name = 'Other' WHERE product_name IN ('NULL', 'Unknown', '');

-- Fix common NULLs or blanks before changing type
UPDATE products
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

---change datatype to datetime
ALTER TABLE products ALTER COLUMN created_at DATETIME