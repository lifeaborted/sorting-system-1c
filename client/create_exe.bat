if exist build\ (
	echo "folder [build] exists. deleting"
	rmdir /s /q "build"
)
if exist dist\ (
	echo "folder [dist] exists. deleting"
	rmdir /s /q "dist"
)
pyinstaller --add-data "main.qml:." --add-data "Components:Components" --add-data "Pages:Pages" --add-data "resources:resources"  --name="Производство гробов v2" --windowed --onefile main.py