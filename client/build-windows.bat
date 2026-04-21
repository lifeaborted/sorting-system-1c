@echo off

echo Проверка установки Python...
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python не установлен. Установите версию не ниже 3.11
    exit /b 1
)

echo Проверка версии Python...
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set PYTHON_MINOR=%%b
)
if %PYTHON_MINOR% LSS 11 (
	echo Установлена старая версия Python. Установите версию не ниже 3.11
    exit /b 1
)

echo Проверка виртуального окружения...
if not exist "venv\" (
	echo Создание виртуального окружения...
    python -m venv venv
)
if not exist "venv\" (
	echo Ошибка создания виртуального окружения
    pause
    exit /b 1
)

echo Активация виртуального окружения...
call .\venv\Scripts\activate.bat

cls
echo Установка зависимостей...
pip install -r requirements.txt

cls
setlocal
FOR /F "tokens=*" %%i in ('type build_meta.env') do SET %%i
if exist build\ (
	echo Очистка файлов сборки...
	rmdir /s /q "build"
)
if exist dist\ (
	echo Очистка старой версии...
	rmdir /s /q "dist"
)

echo Начало сборки...
pyinstaller --add-data "main.qml:." --add-data "icon.png:." --add-data "Components:Components" --add-data "ProgramWindow.qml:." --add-data "Pages:Pages" --add-data ".env:." --add-data "resources:resources"   --name=%APP_NAME% --windowed --onefile main.py --icon=%ICON% --exclude-module PyQt5 --hidden-import=dotenv
endlocal

echo Готово

start explorer "%CD%\dist"