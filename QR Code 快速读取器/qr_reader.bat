@echo off
setlocal
title 二維碼讀取工具

:: 檢查是否有拖曳圖片
if "%~1"=="" (
    echo.
    echo 請將二維碼圖片拖曳到此檔案上。
    pause
    exit /b
)

:: 執行 Python 腳本，並捕捉錯誤碼
python "%~dp0qr_read.py" "%~1"
if errorlevel 1 (
    echo.
    echo ? 發生錯誤，請檢查圖片是否為有效的二維碼圖片。
    pause
)
