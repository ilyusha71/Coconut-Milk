@echo off
setlocal enabledelayedexpansion

REM 檢查是否拖入文件
if "%~1"=="" (
    echo 請將一個視頻文件拖曳到此bat文件上運行。
    pause
    exit /b
)

REM 取得原始文件信息
set "input=%~1"
set "filename=%~n1"
set "ext=%~x1"

REM 設定輸出文件名稱
set "output=%~dp1%filename% 4K超清.mp4"

REM 使用ffmpeg複製視訊與音訊流，僅清除 title 與 comment metadata
ffmpeg -i "%input%" -c:v copy -c:a copy -metadata title= -metadata comment= -movflags +faststart "%output%"

echo.
echo 轉換完成！

:: 播放提示音（辨識度高）
powershell -c "(New-Object Media.SoundPlayer 'C:\Windows\Media\Windows Notify Calendar.wav').PlaySync()"

pause
