
USE E_Commerce_Project


--------------------------------------------DATA CLEANING--------------------------------------------------------
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