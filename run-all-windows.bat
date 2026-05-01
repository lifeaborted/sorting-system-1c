@echo off
echo Запуск сервисов...

start "Server" cmd /c "cd /d server && run-windows.bat"
timeout /t 3 /nobreak
start "Neural" cmd /c "cd /d neural && run-windows.bat"
timeout /t 5 /nobreak
start "Client" cmd /c "cd /d client && run-windows.bat"

echo Все сервисы запущены