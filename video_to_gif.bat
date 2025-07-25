@echo off
setlocal enabledelayedexpansion
title 視頻轉GIF工具

echo.
echo ========================================
echo       視頻 → 動態GIF 轉換工具
echo ========================================
echo.

:: 取得文件路徑
set "videofile=%~1"
if "%videofile%"=="" (
    set /p videofile=請輸入視頻文件路徑或拖入：
)

:: 移除可能多余引�迭]避免��重引�迭^
set "videofile=%videofile:"=%"

:: 檢查是否存在
if not exist "%videofile%" (
    echo 錯誤：找不到該文件！
    pause > nul
    exit /b 1
)

:: 呼叫 Python 腳本
python "%~dp0video_to_gif_byWindow.py" "%videofile%"
if errorlevel 1 (
    echo.
    echo 錯誤：Python 腳本執行失敗，請檢查 Python 環境及腳本。
) else (
    echo.
    echo 轉換完成！
)

pause > nul
exit /b
