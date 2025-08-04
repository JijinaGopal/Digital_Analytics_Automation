@echo off

echo STEP 1: Import all files into SQL Server and clean ...
sqlcmd -S LAPTOP-2K6MH8QU\SQLEXPRESS -d E_Commerce_Project -E -i "C:\Users\Administrator\Desktop\Automation\SQL_Cleaning.sql" > "C:\Users\Administrator\Desktop\Automation\Output.txt"

echo -----------------------------------

echo STEP 2: Export cleaned data to folder
"C:\Users\Administrator\AppData\Local\Programs\Python\Python39\python.exe" "C:\Users\Administrator\Desktop\Automation\run_pipeline.py"

echo -----------------------------------

echo STEP 3: Git push changes to GitHub...
cd "C:\Users\Administrator\Desktop\Automation"
git add .
git commit -m "Auto update after SQL cleaning - %DATE% %TIME%"
git push origin main

echo -----------------------------------

echo DONE. Streamlit Cloud will reflect the changes shortly.
pause

