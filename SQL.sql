
USE E_Commerce_Project

--------------------------------------------DATA CLEANING--------------------------------------------------------
TRUNCATE TABLE orders;

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
SET created_at = CONVERT(varchar, TRY_CONVERT(datetime, created_at), 120)
WHERE TRY_CONVERT(datetime, created_at) IS NOT NULL;

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
WHERE order_item_id IS NULL OR created_at IS NULL;

UPDATE order_items
SET created_at = CONVERT(varchar, TRY_CONVERT(datetime, created_at), 120)
WHERE TRY_CONVERT(datetime, created_at) IS NOT NULL;

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
WHERE order_item_refund_id IS NULL OR created_at IS NULL;

UPDATE order_item_refunds
SET created_at = CONVERT(varchar, TRY_CONVERT(datetime, created_at), 120)
WHERE TRY_CONVERT(datetime, created_at) IS NOT NULL;

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

TRUNCATE TABLE website_pageviews;

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
SET created_at = CONVERT(varchar, TRY_CONVERT(datetime, created_at), 120)
WHERE TRY_CONVERT(datetime, created_at) IS NOT NULL;

TRUNCATE TABLE website_sessions;
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

UPDATE website_sessions
SET created_at = CONVERT(varchar, TRY_CONVERT(datetime, created_at), 120),
    utm_source = ISNULL(utm_source, 'unknown'),
    utm_campaign = ISNULL(utm_campaign, 'unknown'),
    utm_content = ISNULL(utm_content, 'unknown'),
    device_type = ISNULL(device_type, 'unknown'),
    http_referer = ISNULL(http_referer, 'unknown')
WHERE TRY_CONVERT(datetime, created_at) IS NOT NULL;

