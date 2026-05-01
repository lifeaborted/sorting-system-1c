import json
import logging
import os
from os import mkdir
from os.path import exists
from typing import TypedDict, Optional, NotRequired

import platformdirs
from platformdirs import PlatformDirs


class Config(TypedDict):
    token: NotRequired[str]
    language: NotRequired[str]


dirs = PlatformDirs("QtSort1c")
def load_config() -> Config:
    logging.info(f"[CONF] Trying to load config path={_cfg_path()}")
    conf: Config = None
    try:
        f = open(_cfg_path())
        conf = json.loads(f.read(-1))
        f.close()
    except Exception as e:
        logging.info(f"[CONF] Failed to open config ({e}). Creating new")
        conf = _default_config()
    return conf

def save_config(conf: Config):
    if not exists(dirs.user_config_dir):
        os.makedirs(dirs.user_config_dir)
    logging.info(f"[CONF] Saving config path={_cfg_path()}")
    f = open(_cfg_path(), "w")
    f.write(json.dumps(conf))
    f.close()


def _cfg_path() -> str:
    return os.path.join(dirs.user_config_dir, "config.json")

def _default_config() -> Config:
    return Config(
        language="ru"
    )