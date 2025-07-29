@echo off

echo STEP 1: Import website_sessions.csv into SQL Server and clean ...
sqlcmd -S LAPTOP-2K6MH8QU\SQLEXPRESS -d E_Commerce_Project -E -i "C:\Users\Administrator\Desktop\Automation\SQL.sql"

echo -----------------------------------


echo STEP 2: Export cleaned w_sessions table to CSV...
bcp "SELECT * FROM E_Commerce_Project.dbo.w_sessions" queryout "C:\Users\Administrator\Desktop\Automation\data\w_sessions.csv" -c -t, -S LAPTOP-2K6MH8QU\SQLEXPRESS -T -d E_Commerce_Project

echo -----------------------------------

echo STEP 3: Git push changes to GitHub...
cd "C:\Users\Administrator\Desktop\Automation"
git add .
git commit -m "Auto update after SQL cleaning - %DATE% %TIME%"
git push origin main

echo -----------------------------------

echo DONE. Streamlit Cloud will reflect the changes shortly.
pause

