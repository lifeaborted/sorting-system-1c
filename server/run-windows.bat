@echo off

node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ОШИБКА: Node.js не установлен
    pause
    exit /b 1
)

echo Node.js установлен
cls

if not exist "node_modules" (
    npm install --verbose 
)

cls

if not exist ".env" (
    setlocal enabledelayedexpansion

    echo Создание файла .env
    echo.

    set DEFAULT_DB_PORT=5432
    set DEFAULT_DB_HOST=localhost
    set DEFAULT_DB_USER=postgres
    set DEFAULT_PORT=5000
    set DEFAULT_ENCRYPTION_SALT=6fe1487911
    set DEFAULT_JWT_PASSWORD_CODE=efdc97875ae97d75507b415902eabbc5
    set DEFAULT_JWT_PASSWORD_DURATION=24

    echo [1/3] Настройка порта базы данных
    set /p CHANGE_PORT="Изменить порт БД? (y/n): "
    if /i "!CHANGE_PORT!"=="y" (
        set /p DB_PORT="Введите порт БД: "
        echo   Порт установлен: !DB_PORT!
    ) else (
        set DB_PORT=!DEFAULT_DB_PORT!
        echo   Порт по умолчанию: !DB_PORT!
    )
    echo.

    echo [2/3] Настройка имени базы данных
    set /p DB_NAME="Введите название базы данных: "
    if "!DB_NAME!"=="" (
        echo   ОШИБКА: Название БД не может быть пустым!
        pause
        exit /b 1
    )
    echo   Название БД: !DB_NAME!
    echo.

    echo [3/3] Настройка пароля базы данных
    set /p DB_PASSWORD="Введите пароль базы данных: "
    if "!DB_PASSWORD!"=="" (
        echo ВНИМАНИЕ: Пароль пуст!
    ) else (
        echo Пароль установлен
    )
    echo.

    echo Создание файла .env...
    (
    echo DB_HOST=!DEFAULT_DB_HOST!
    echo DB_PORT=!DB_PORT!
    echo DB_NAME=!DB_NAME!
    echo DB_USER=!DEFAULT_DB_USER!
    echo DB_PASSWORD=!DB_PASSWORD!
    echo.
    echo PORT=!DEFAULT_PORT!
    echo.
    echo ENCRYPTION_SALT=!DEFAULT_ENCRYPTION_SALT!
    echo JWT_PASSWORD_CODE=!DEFAULT_JWT_PASSWORD_CODE!
    echo JWT_PASSWORD_DURATION=!DEFAULT_JWT_PASSWORD_DURATION!
    ) > .env

    endlocal
)

cls

node index.js