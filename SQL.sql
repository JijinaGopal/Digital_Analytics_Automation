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
    CODEPAGE = 'ACP'
);

DELETE FROM website_sessions
WHERE website_session_id IS NULL OR created_at IS NULL;

-- Fix common NULLs or blanks before changing type
UPDATE website_sessions
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

ALTER TABLE website_sessions ALTER COLUMN created_at DATETIME;

-- Clean other fields
UPDATE website_sessions
SET utm_source = ISNULL(utm_source, 'unknown'),
    utm_campaign = ISNULL(utm_campaign, 'unknown'),
    utm_content = ISNULL(utm_content, 'unknown'),
    device_type = ISNULL(device_type, 'unknown'),
    http_referer = ISNULL(http_referer, 'unknown');

-- Copy cleaned data to w_sessions
TRUNCATE TABLE w_sessions;

INSERT INTO w_sessions
SELECT *
FROM website_sessions;


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
    CODEPAGE = 'ACP'
);

DELETE FROM website_pageviews
WHERE website_pageview_id IS NULL OR created_at IS NULL;

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
    CODEPAGE = 'ACP'
);

DELETE FROM orders
WHERE order_id IS NULL OR created_at IS NULL;

UPDATE orders
SET created_at = NULL
WHERE TRY_CONVERT(datetime, created_at) IS NULL;

ALTER TABLE orders ALTER COLUMN created_at DATETIME;


-- ---------------------- 4. order_items ----------------------
TRUNCATE TABLE order_items;

BULK INSERT order_items
FROM 'C:\Users\Administrator\Desktop\Automation\data\order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP'
);

DELETE FROM order_items
WHERE order_item_id IS NULL;


-- ---------------------- 5. order_item_refunds ----------------------
TRUNCATE TABLE order_item_refunds;

BULK INSERT order_item_refunds
FROM 'C:\Users\Administrator\Desktop\Automation\data\order_item_refunds.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP'
);

DELETE FROM order_item_refunds
WHERE order_item_refund_id IS NULL;


-- ---------------------- 6. products ----------------------
TRUNCATE TABLE products;

BULK INSERT products
FROM 'C:\Users\Administrator\Desktop\Automation\data\products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP'
);

DELETE FROM products
WHERE product_id IS NULL;


