@echo off

echo Проверка установки Python...
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python не установлен. Установите версию 3.13
    exit /b 1
)

echo Проверка версии Python...
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set PYTHON_MINOR=%%b
)
if %PYTHON_MINOR% LSS 13 (
	echo Установлена старая версия Python. Установите версию не ниже 3.13
    exit /b 1
)

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
echo Настройка окружения...

setlocal enabledelayedexpansion

set ENV_FILE=.env

:: Проверяем, существует ли .env файл
if not exist "%ENV_FILE%" (
    echo Файл %ENV_FILE% не найден. Создание нового файла...
	echo.
	set /p API_TOKEN="Введите API токен: "

	if "!API_TOKEN!"=="" (
	    echo Токен не может быть пустым!
	    goto :eof
	)

	(
	    echo PORT=5000
		echo SCANNER_API_KEY=!API_TOKEN!
	) > "%ENV_FILE%"

)

if exist "%ENV_FILE%" (
    echo .env файл найден
) else (
    echo Ошибка: Не удалось создать файл %ENV_FILE%!
)
endlocal


cls

echo Запуск...
python src/main.py
pause