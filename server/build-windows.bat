@echo off

node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ОШИБКА: Node.js не установлен
    pause
    exit /b 1
)

echo Node.js установлен
cls

call npm install --save-dev --verbose 

cls

if not exist ".env" (
    echo ERROR: .env file is not exist
    pause
    exit /b 1
)

cls

call npm run build

start explorer "%CD%\dist"

pause