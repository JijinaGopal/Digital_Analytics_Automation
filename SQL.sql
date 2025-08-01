USE E_Commerce_Project;

-- ---------------------- 1. website_sessions ----------------------
TRUNCATE TABLE website_sessions;

ALTER TABLE website_sessions ALTER COLUMN created_at VARCHAR(50);

BULK INSERT website_sessions
FROM 'C:\Users\Administrator\Desktop\Automation\data\website_sessions.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP',
    KEEPNULLS
);

WITH cte AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY website_session_id, created_at, user_id, is_repeat_session, utm_source, utm_campaign, utm_content, device_type, http_referer
        ORDER BY (SELECT NULL)
    ) AS rn
    FROM website_sessions
)
DELETE FROM cte WHERE rn > 1;

UPDATE website_sessions
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

ALTER TABLE website_sessions ALTER COLUMN created_at DATETIME;

UPDATE website_sessions
SET utm_source     = ISNULL(NULLIF(LTRIM(RTRIM(utm_source)), ''), 'unknown'),
    utm_campaign   = ISNULL(NULLIF(LTRIM(RTRIM(utm_campaign)), ''), 'unknown'),
    utm_content    = ISNULL(NULLIF(LTRIM(RTRIM(utm_content)), ''), 'unknown'),
    device_type    = ISNULL(NULLIF(LTRIM(RTRIM(device_type)), ''), 'unknown'),
    http_referer   = ISNULL(NULLIF(LTRIM(RTRIM(http_referer)), ''), 'unknown');

TRUNCATE TABLE w_sessions;

INSERT INTO w_sessions
SELECT * FROM website_sessions;


-- ---------------------- 2. website_pageviews ----------------------
TRUNCATE TABLE website_pageviews;

ALTER TABLE website_pageviews ALTER COLUMN created_at VARCHAR(50);

BULK INSERT website_pageviews
FROM 'C:\Users\Administrator\Desktop\Automation\data\website_pageviews.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP',
    KEEPNULLS
);

WITH cte AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY website_pageview_id, created_at, website_session_id, pageview_url
        ORDER BY (SELECT NULL)
    ) AS rn
    FROM website_pageviews
)
DELETE FROM cte WHERE rn > 1;

UPDATE website_pageviews
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

ALTER TABLE website_pageviews ALTER COLUMN created_at DATETIME;


-- ---------------------- 3. orders ----------------------
TRUNCATE TABLE orders;

ALTER TABLE orders ALTER COLUMN created_at VARCHAR(50);

BULK INSERT orders
FROM 'C:\Users\Administrator\Desktop\Automation\data\orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP',
    KEEPNULLS
);

WITH cte AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY order_id, created_at, website_session_id, user_id, primary_product_id, items_purchased, price_usd, cogs_usd
        ORDER BY (SELECT NULL)
    ) AS rn
    FROM orders
)
DELETE FROM cte WHERE rn > 1;

IF EXISTS (SELECT 1 FROM orders WHERE price_usd <= 0 OR cogs_usd <= 0)
    PRINT 'Invalid price or cost in orders';

IF EXISTS (SELECT 1 FROM orders WHERE items_purchased < 0)
    PRINT 'Invalid item quantity in orders';

UPDATE orders
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

ALTER TABLE orders ALTER COLUMN created_at DATETIME;


-- ---------------------- 4. order_items ----------------------
TRUNCATE TABLE order_items;

ALTER TABLE order_items ALTER COLUMN created_at VARCHAR(50);

BULK INSERT order_items
FROM 'C:\Users\Administrator\Desktop\Automation\data\order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP',
    KEEPNULLS
);

WITH cte AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY order_item_id, created_at, order_id, product_id, is_primary_item, price_usd, cogs_usd
        ORDER BY (SELECT NULL)
    ) AS rn
    FROM order_items
)
DELETE FROM cte WHERE rn > 1;

UPDATE order_items
SET is_primary_item = 0
WHERE is_primary_item IS NULL;

UPDATE order_items
SET price_usd = 0 WHERE price_usd IS NULL;
UPDATE order_items
SET cogs_usd  = 0 WHERE cogs_usd IS NULL;

IF EXISTS (SELECT 1 FROM order_items WHERE price_usd <= 0 OR cogs_usd <= 0)
    PRINT 'Invalid price or cost in order_items';

IF EXISTS (
    SELECT 1 FROM order_items WHERE order_id NOT IN (SELECT order_id FROM orders)
)
    PRINT 'Orphan order_id in order_items';

UPDATE order_items
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

ALTER TABLE order_items ALTER COLUMN created_at DATETIME;


-- ---------------------- 5. order_item_refunds ----------------------
TRUNCATE TABLE order_item_refunds;

ALTER TABLE order_item_refunds ALTER COLUMN created_at VARCHAR(50);

BULK INSERT order_item_refunds
FROM 'C:\Users\Administrator\Desktop\Automation\data\order_item_refunds.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP',
    KEEPNULLS
);

WITH cte AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY order_item_refund_id, created_at, order_item_id, order_id, refund_amount_usd
        ORDER BY (SELECT NULL)
    ) AS rn
    FROM order_item_refunds
)
DELETE FROM cte WHERE rn > 1;

UPDATE order_item_refunds
SET refund_amount_usd = 0
WHERE refund_amount_usd IS NULL;

IF EXISTS (
    SELECT 1 FROM order_item_refunds A
    JOIN order_items B ON A.order_item_id = B.order_item_id
    WHERE A.refund_amount_usd > B.price_usd
)
    PRINT 'Refund exceeds item price';

IF EXISTS (
    SELECT 1 FROM order_item_refunds
    WHERE order_item_id NOT IN (SELECT order_item_id FROM order_items)
)
    PRINT 'Orphan order_item_id in refunds';

IF EXISTS (
    SELECT order_item_id FROM order_item_refunds
    GROUP BY order_item_id HAVING COUNT(*) > 1
)
    PRINT 'Multiple refunds for single order item';

UPDATE order_item_refunds
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

ALTER TABLE order_item_refunds ALTER COLUMN created_at DATETIME;


-- ---------------------- 6. products ----------------------
TRUNCATE TABLE products;

ALTER TABLE products ALTER COLUMN created_at VARCHAR(50);

BULK INSERT products
FROM 'C:\Users\Administrator\Desktop\Automation\data\products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP',
    KEEPNULLS
);

WITH cte AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY product_id, created_at, product_name
        ORDER BY (SELECT NULL)
    ) AS rn
    FROM products
)
DELETE FROM cte WHERE rn > 1;

UPDATE products
SET product_name = 'Other'
WHERE LTRIM(RTRIM(product_name)) IS NULL
   OR product_name IN ('NULL', 'Unknown', '');

UPDATE products
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

ALTER TABLE products ALTER COLUMN created_at DATETIME;

