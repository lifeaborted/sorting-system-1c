# This Python file uses the following encoding: utf-8
import logging
import sys
from pathlib import Path
from typing import Optional, TypedDict, NotRequired

from PySide6.QtCore import QObject, Slot, Property, Signal, QTranslator
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QmlElement, QmlSingleton, QJSValue
from PySide6.QtQuick import QQuickItem

from controller.config import Config, save_config

QML_IMPORT_NAME = "io.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0



@QmlElement
class Translator(QObject):
    translator: Optional[QTranslator] = None
    def __init__(self, app: QGuiApplication, engine: QQmlApplicationEngine, config: Config, parent = None):
        self._app = app
        self._engine = engine
        self._config = config
        self.translate(self._config.get("language", "ru"))
        super().__init__(parent)

    @Slot(str)
    def translate(self, lang: str):
        if lang in self._language_list():
            if self.translator is not None:
                self._app.removeTranslator(self.translator)
            self.translator = QTranslator()
            if self.translator.load(f":/translation/{lang}.qm"):
                self._app.installTranslator(self.translator)
                self._engine.retranslate()
                self._log(f"Changed language to {lang}")

            self._config["language"] = lang
            save_config(self._config)
        else:
            self._log_err(f"Unknown language={lang}")

    @Slot(result="QVariantList")
    def language_list(self):
        return self._language_list()

    @Slot(result=str)
    def current_language(self):
        return self._config.get("language", "ru")

    def _language_list(self) -> list[str]:
        return ["ru", "en", "zn", "es", "de", "fr", "pt", "ar", "hi"]

    def _log_err(self, text: str):
        logging.error(f"[Translator] {text}")

    def _log(self, text: str):
        logging.info(f"[Translator] {text}")
