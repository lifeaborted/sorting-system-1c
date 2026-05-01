# This Python file uses the following encoding: utf-8
import logging
import os
import sys
from pathlib import Path

from PySide6.QtCore import QObject, QTranslator, QLocale
from PySide6.QtGui import QGuiApplication, QFont, QFontDatabase, QIcon
from PySide6.QtQml import QQmlApplicationEngine, qmlContext
from dotenv import load_dotenv

import controller.backend
from controller.backend import Backend, execute_shutdown
import rc_resources

if __name__ == "__main__":
    logging.basicConfig(
        format='[%(asctime)s] [%(levelname)s] %(message)s',
        level=logging.INFO,
        datefmt='%Y-%m-%d %H:%M:%S')
    logging.info("Logger init")


    app = QGuiApplication(sys.argv)
    if getattr(sys, 'frozen', False):
        bundle_dir = sys._MEIPASS
        dotenv_path = os.path.join(bundle_dir, '.env')
        app.setWindowIcon(QIcon(os.path.join(bundle_dir, 'icon.png')))
        load_dotenv(dotenv_path=dotenv_path)
    else:
        app.setWindowIcon(QIcon('icon.png'))
        if not os.path.exists(".env"):
            logging.error("Failed to read .env .")
            sys.exit(-1)
        load_dotenv(".env")

    engine = QQmlApplicationEngine()

    controller.backend.QENGINE = engine
    controller.backend.QAPP = app

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

    code = app.exec()
    execute_shutdown()

    sys.exit(code)
