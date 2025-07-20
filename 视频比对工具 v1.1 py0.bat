@echo off
setlocal enabledelayedexpansion
title 視頻比對工具 by 163

:: 檢查 Python 是否可用
where python >nul 2>&1 || (
    echo 錯誤：找不到 python 請先安裝並設置環境變量
    pause
    exit /b
)

:: 檢查 ffprobe 是否可用
where ffprobe >nul 2>&1 || (
    echo 錯誤：找不到 ffprobe 請先安裝 ffmpeg 並設置環境變量
    pause
    exit /b
)

if "%~2" neq "" (
    :: 有兩個參數，直接傳給 python 腳本
    python "%~dp0probe_compare.py" "%~1" "%~2"
    pause
    exit /b
)

:: 無參數，交互輸入
echo ==============================
echo 視頻比對工具 by 163
echo ==============================
echo.

set /p "file1=請拖入第一個文件或輸入路徑："
set "file1=%file1:"=%"
for %%A in ("%file1%") do set "file1=%%~fA"

if not exist "!file1!" (
    echo 錯誤：第一個文件不存在
    pause
    exit /b
)

set /p "file2=請拖入第二個文件或輸入路徑："
set "file2=%file2:"=%"
for %%A in ("%file2%") do set "file2=%%~fA"

if not exist "!file2!" (
    echo 錯誤：第二個文件不存在
    pause
    exit /b
)

python "%~dp0probe_compare.py" "!file1!" "!file2!"
pause
exit /b
