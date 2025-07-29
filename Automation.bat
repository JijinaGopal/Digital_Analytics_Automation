@echo off


cd "C:\Users\Administrator\Desktop\Automation"


sqlcmd -S LAPTOP-2K6MH8QU\SQLEXPRESS -d E_COMMERCE -E -i "C:\Users\Administrator\Desktop\Automation\SQL.sql"


git add .
git commit -m "Auto update data - %DATE% %TIME%"
git push origin main

echo Done! Streamlit Cloud will pick up changes.
pause
