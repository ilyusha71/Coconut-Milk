@echo off
setlocal enabledelayedexpansion
title YouTube 多線程下載器

echo ===========================================
echo     YouTube 多線程下載器 (yt-dlp + aria2c)
echo         支援畫質選擇、影片合併
echo ===========================================

set /p url=請貼上 YouTube 影片連結：

if "%url%"=="" (
    echo 錯誤：未輸入連結！
    pause
    exit /b 1
)

echo.
echo 【可用畫質清單】
yt-dlp.exe -F "%url%"
echo.

set /p fmt=請輸入想要下載的格式代號（可為「137+140」格式）：

if "%fmt%"=="" (
    echo 錯誤：未輸入格式代號！
    pause
    exit /b 1
)

echo.
echo 開始下載格式 %fmt% 的影片與音訊...
yt-dlp.exe -f %fmt% --merge-output-format mp4 ^
 --external-downloader aria2c ^
 --external-downloader-args "-x 16 -s 10 -c" "%url%"

echo.
echo 下載完成！
pause
