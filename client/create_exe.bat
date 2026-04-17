setlocal
FOR /F "tokens=*" %%i in ('type build_meta.env') do SET %%i
if exist build\ (
	echo "folder [build] exists. deleting"
	rmdir /s /q "build"
)
if exist dist\ (
	echo "folder [dist] exists. deleting"
	rmdir /s /q "dist"
)
pyinstaller --add-data "main.qml:." --add-data "Components:Components" --add-data "ProgramWindow.qml:." --add-data "Pages:Pages" --add-data "resources:resources"  --name=%APP_NAME% --windowed --onefile main.py --icon=%ICON%
endlocal