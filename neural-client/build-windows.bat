@echo off

node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ОШИБКА: Node.js не установлен
    pause
    exit /b 1
)

echo Node.js установлен
cls

rustup -V >nul 2>&1
if %errorlevel% neq 0 (
    echo ОШИБКА: Rust не установлен
    pause
    exit /b 1
)

echo Rust установлен
cls

call npm install --save-dev --verbose 

cls

call npm run tauri build

start explorer "%CD%\src-tauri\target\release"

pause