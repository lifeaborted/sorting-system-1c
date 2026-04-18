source build_meta.env
if [ -d build ]; then
	echo "folder [build] exists. deleting"
	rm -r "build"
fi
if [ -d dist ]; then
	echo "folder [dist] exists. deleting"
	rm -r "dist"
fi
pyinstaller --add-data "main.qml:." --add-data "Components:Components" --add-data "ProgramWindow.qml:." --add-data "Pages:Pages" --add-data "resources:resources"  --name="$APP_NAME" --windowed --onefile main.py --icon="$ICON"