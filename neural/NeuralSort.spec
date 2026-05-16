# -*- mode: python ; coding: utf-8 -*-
from PyInstaller.utils.hooks import collect_submodules
from PyInstaller.utils.hooks import collect_all

datas = [('data', 'data'), ('dataset', 'synthetic_dataset'), ('yolov8n.pt', '.'), ('runs', 'runs')]
binaries = []
hiddenimports = ['paddle', 'paddleocr', 'ultralytics', 'cv2', 'numpy', 'fastapi', 'uvicorn', 'loguru', 'cryptography', 'dotenv', 'python_multipart', 'skimage', 'PIL', 'PIL._imaging', 'timeit', 'html.parser', 'xml', 'xml.etree', 'sqlite3', 'statistics', 'typing_extensions', 'opt_einsum', 'jinja2', 'fsspec', 'filelock', 'networkx', 'sympy', 'modulefinder', 'colorlog', 'symtable', 'wave', 'chunk', 'sndhdr', 'imghdr', 'colorsys', 'audioop', 'aifc', 'sunau']
hiddenimports += collect_submodules('paddle')
tmp_ret = collect_all('paddleocr')
datas += tmp_ret[0]; binaries += tmp_ret[1]; hiddenimports += tmp_ret[2]
tmp_ret = collect_all('paddle')
datas += tmp_ret[0]; binaries += tmp_ret[1]; hiddenimports += tmp_ret[2]
tmp_ret = collect_all('ultralytics')
datas += tmp_ret[0]; binaries += tmp_ret[1]; hiddenimports += tmp_ret[2]
tmp_ret = collect_all('cv2')
datas += tmp_ret[0]; binaries += tmp_ret[1]; hiddenimports += tmp_ret[2]


a = Analysis(
    ['src\\server.py'],
    pathex=['src'],
    binaries=binaries,
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=['matplotlib', 'tensorflow', 'torch', 'paddle', 'paddleocr', 'paddlex', 'ultralytics'],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='NeuralSort',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=False,
    upx_exclude=[],
    name='NeuralSort',
)
