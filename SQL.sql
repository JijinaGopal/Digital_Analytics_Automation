
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



-- Truncate and import website_sessions
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



-- Drop the table if it already exists 
IF OBJECT_ID('dbo.w_sessions', 'U') IS NOT NULL
    DROP TABLE dbo.w_sessions;


SELECT *
INTO dbo.w_sessions
FROM dbo.website_sessions;

---Delete null
DELETE FROM orders
WHERE order_id IS NULL
or created_at IS NULL

DELETE FROM order_items
WHERE order_item_id IS NULL
or created_at IS NULL

DELETE FROM order_item_refunds
WHERE order_item_refund_id IS NULL
or created_at IS NULL

DELETE FROM website_pageviews
WHERE website_pageview_id IS NULL
or created_at IS NULL


DELETE FROM w_sessions
WHERE website_session_id IS NULL
or created_at IS NULL


---updating nulls with unknown
UPDATE w_sessions
SET                           
    utm_source        = ISNULL(utm_source, 'unknown'),
    utm_campaign      = ISNULL(utm_campaign, 'unknown'),
    utm_content       = ISNULL(utm_content, 'unknown'),
    device_type       = ISNULL(device_type, 'unknown'),
    http_referer      = ISNULL(http_referer, 'unknown')
WHERE
    is_repeat_session IS NULL OR
    utm_source IS NULL OR
    utm_campaign IS NULL OR
    utm_content IS NULL OR
    device_type IS NULL OR
    http_referer IS NULL;

