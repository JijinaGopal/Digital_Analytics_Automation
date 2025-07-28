@echo off


cd "C:\Users\Administrator\Desktop\Automation\Digital_Analytics_WebApp"


copy /Y "C:\Users\Administrator\Desktop\Automation\data\orders.csv" "data\orders.csv"
copy /Y "C:\Users\Administrator\Desktop\Automation\data\order_items.csv" "data\order_items.csv"
copy /Y "C:\Users\Administrator\Desktop\Automation\data\order_item_refunds.csv" "data\order_item_refunds.csv"
copy /Y "C:\Users\Administrator\Desktop\Automation\data\products.csv" "data\products.csv"
copy /Y "C:\Users\Administrator\Desktop\Automation\data\w_sessions.csv" "data\w_sessions.csv"
copy /Y "C:\Users\Administrator\Desktop\Automation\data\website_pageviews.csv" "data\website_pageviews.csv"


git add .
git commit -m "Auto update data - %DATE% %TIME%"
git push origin main

echo Done! Streamlit Cloud will pick up changes.
pause
