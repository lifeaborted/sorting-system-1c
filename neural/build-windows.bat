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


cls
echo Проверка виртуального окружения...
if not exist "venv\" (
    echo Создание виртуального окружения...
    call python -m venv venv
)

echo Активация виртуального окружения...
call .\venv\Scripts\activate.bat


cls
echo Установка зависимостей...
call pip install -r build-requirements.txt


cls
echo Настройка окружения...


cls
if exist "build" rmdir /s /q build
if exist "dist\NeuralSort" rmdir /s /q dist\NeuralSort

call pyinstaller NeuralSort.spec -y

set SRC=venv\Lib\site-packages
set DST=dist\NeuralSort\_internal

if exist "dist\NeuralSort" (
    del /q "dist\NeuralSort\_internal\msvcp140.dll" 2>nul
    del /q "dist\NeuralSort\_internal\vcruntime140.dll" 2>nul
    del /q "dist\NeuralSort\_internal\vcruntime140_1.dll" 2>nul
    del /q "dist\NeuralSort\_internal\libiomp5md.dll" 2>nul
    del /q "dist\NeuralSort\_internal\vcomp140.dll" 2>nul
    xcopy "%SRC%\google" "%DST%\google\" /E /I /Y /Q
    xcopy "%SRC%\PIL" "%DST%\PIL\" /E /I /Y /Q
    xcopy /E /I /Y data dist\NeuralSort\data\
    xcopy /E /I /Y runs dist\NeuralSort\runs\
    xcopy /E /I /Y dataset dist\NeuralSort\dataset\
    copy /Y yolov8n.pt dist\NeuralSort\ 2>nul
    for /d %%i in ("%SRC%\aistudio_sdk*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\lxml*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\colorlog*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\httpx*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\huggingface_hub*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\modelscope*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\paddle*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\pillow*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\prettytable*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\ruamel*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\safetensors*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\setuptools*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\torch*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\tqdm*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\pyclipper*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\pypdfium*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    for /d %%i in ("%SRC%\zstandard*") do xcopy "%%i" "%DST%\%%~nxi\" /E /I /Y /Q
    xcopy "%SRC%\*.dll" "%DST%\" /Y /Q
)

echo Done!
pause