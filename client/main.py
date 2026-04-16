# This Python file uses the following encoding: utf-8
import logging
import sys
from pathlib import Path

from PySide6.QtCore import QObject
from PySide6.QtGui import QGuiApplication, QFont, QFontDatabase
from PySide6.QtQml import QQmlApplicationEngine, qmlContext

from controller.backend import Backend
import rc_resources

if __name__ == "__main__":
    logging.basicConfig(
        format='[%(asctime)s] [%(levelname)s] %(message)s',
        level=logging.INFO,
        datefmt='%Y-%m-%d %H:%M:%S')
    logging.info("Logger init")
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "main.qml"
    # dunno if needed
    engine.addImportPath(sys.path[0].join("/controller"))
    engine.load(qml_file)


    ''' василий поменяешь если чето не понравится
    '''
    #👍👍👍👍👍👍👍 ok ^

    # Font loading
    font_ids = [
        QFontDatabase.addApplicationFont(":/resources/fonts/Roboto-Regular.ttf"),
        QFontDatabase.addApplicationFont(":/resources/fonts/Roboto-Medium.ttf"),
        QFontDatabase.addApplicationFont(":/resources/fonts/Roboto-Bold.ttf")
    ]

    # Default font for entire app
    default_font = QFont("Roboto", 12)
    app.setFont(default_font)



    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
