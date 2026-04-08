# This Python file uses the following encoding: utf-8
import logging
import sys
from pathlib import Path

from PySide6.QtCore import QObject
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlContext

from controller.router import Router
import rc_resources

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "main.qml"
    # dunno if needed
    engine.addImportPath(sys.path[0].join("/controller"))
    engine.load(qml_file)


    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
