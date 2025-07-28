@echo off


cd "C:\Users\Administrator\Desktop\Automation"


git add .
git commit -m "Auto update data - %DATE% %TIME%"
git push origin main

echo Done! Streamlit Cloud will pick up changes.
pause
