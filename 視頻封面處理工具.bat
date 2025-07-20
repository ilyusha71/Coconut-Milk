@echo off
setlocal enabledelayedexpansion
title 視頻封面處理工具

REM 檢查是否拖入檔案
if "%~1"=="" (
    echo 請將 MP4 檔案拖入此批次檔。
    pause
    exit /b
)

set "videoFile=%~1"
set "baseName=%~dpn1"
set "extName=%~x1"

echo.
echo 處理的影片檔：%videoFile%
echo.

echo 選擇操作：
echo 1. 添加封面（無封面時用）
echo 2. 更換封面
echo 3. 提取封面
echo 4. 刪除封面
set /p choice=請輸入數字並按下 Enter：

if "%choice%"=="1" goto :add_cover
if "%choice%"=="2" goto :replace_cover
if "%choice%"=="3" goto :extract_cover
if "%choice%"=="4" goto :remove_cover

echo 無效選項。
pause
exit /b

:add_cover
call :select_image
if not exist "!imgFile!" (
    echo 找不到圖片檔案。
    pause
    exit /b
)
ffmpeg -i "%videoFile%" -i "!imgFile!" -map 0 -map 1 -c copy ^
    -metadata:s:v:1 title="Album cover" -metadata:s:v:1 comment="Cover (front)" -disposition:v:1 attached_pic ^
    "%baseName%_添加封面%extName%" -y
echo 封面已添加。
pause
exit /b

:replace_cover
call :select_image
if not exist "!imgFile!" (
    echo 找不到圖片檔案。
    pause
    exit /b
)
echo 正在更換封面...

REM 移除原封面
ffmpeg -i "%videoFile%" -map 0 -map -0:v:1 -c copy "temp_no_cover%extName%" -y

REM 將圖片轉為 jpg
ffmpeg -i "!imgFile!" -frames:v 1 -q:v 2 "temp_cover.jpg" -y

REM 添加新封面
ffmpeg -i "temp_no_cover%extName%" -i "temp_cover.jpg" -map 0 -map 1 -c copy ^
    -metadata:s:v:1 title="Album cover" -metadata:s:v:1 comment="Cover (front)" -disposition:v:1 attached_pic ^
    "%baseName%_更換封面%extName%" -y

REM 清理臨時檔
del "temp_no_cover%extName%" >nul 2>&1
del "temp_cover.jpg" >nul 2>&1

echo 封面已更換成功。
pause
exit /b

:extract_cover
ffmpeg -i "%videoFile%" -an -vcodec copy "%baseName%_封面.jpg" -y
echo 封面已提取為：%baseName%_封面.jpg
pause
exit /b

:remove_cover
ffmpeg -i "%videoFile%" -map 0 -map -0:v:1 -c copy "%baseName%_無封面%extName%" -y
echo 封面已刪除。
pause
exit /b

:select_image
echo 請將封面圖片檔拖入此視窗，然後按 Enter：
set /p imgFile=
set imgFile=%imgFile:"=%
exit /b
