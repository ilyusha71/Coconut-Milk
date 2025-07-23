@echo off
setlocal enabledelayedexpansion

:: 檢查是否拖入了文件
if "%~1"=="" (
    echo 請將 .ts 文件拖放到此腳本上進行轉換。
    pause
    exit /b
)

:: 獲取文件路徑、文件名（無擴展名）
set "input=%~1"
set "filename=%~n1"
set "output=%~dp1%filename%.mp4"

:: 調用 ffmpeg 進行轉換
ffmpeg -i "%input%" -c copy "%output%"

echo.
echo 轉換完成：%output%
pause
