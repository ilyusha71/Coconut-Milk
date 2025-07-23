@echo off
setlocal enabledelayedexpansion

echo 批次檔所在資料夾是：%~dp0

where python >nul 2>nul || (
    echo 請先安裝 Python！
    pause
    exit /b
)

if not exist "%~dp0fix_gbk_garbled.py" (
    echo 找不到 Python 腳本 "%~dp0fix_gbk_garbled.py"
    pause
    exit /b
)

if "%~1"=="" (
    echo 請拖曳檔案到此批次檔以修復亂碼
    pause
    exit /b
)

REM 將批次檔所在路徑存變數，避免循環中解析錯誤
set "batdir=%~dp0"

:loop
if "%~1"=="" goto endloop

echo 正在處理檔案：%~1

REM 用批次檔所在路徑呼叫 Python 腳本，參數用檔案完整路徑
python "%batdir%fix_gbk_garbled.py" "%~f1"

shift
goto loop

:endloop
echo 全部處理完畢！
pause
