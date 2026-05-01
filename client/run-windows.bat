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

setlocal enabledelayedexpansion

set ENV_FILE=.env

if not exist "%ENV_FILE%" (
    echo Файл %ENV_FILE% не найден. Создание нового файла...
	(
	    echo SERVER_URL=http://localhost
		echo PORT=5000
	) > "%ENV_FILE%"

)

if exist "%ENV_FILE%" (
    echo .env файл создан
) else (
    echo Ошибка: Не удалось создать файл %ENV_FILE%!
)
endlocal

echo Проверка виртуального окружения...
if not exist "venv\" (
	echo Создание виртуального окружения...
    call python -m venv venv
)

echo Активация виртуального окружения...
call .\venv\Scripts\activate.bat

cls
echo Установка зависимостей...
call pip install -r requirements.txt

cls

echo Запуск приложения...
python main.py
pause