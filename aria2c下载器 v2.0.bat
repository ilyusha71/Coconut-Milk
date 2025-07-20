@echo off
setlocal enabledelayedexpansion
title aria2c 簡易下載器

:: 輸入連結
set /p url=請輸入下載連結：
if "%url%"=="" (
    echo 錯誤：未輸入連結
    goto end
)

:: 輸入自訂檔名（可留空）
set /p filename=請輸入保存檔名（含副檔名，可留空）：

:: 如果未輸入檔名，直接用預設名稱下載
if "%filename%"=="" (
    aria2c.exe -x 16 -s 10 -c "%url%"
    goto end
)

:: 拆解副檔名
for %%F in ("%filename%") do (
    set "name=%%~nF"
    set "ext=%%~xF"
)

:: 若主名為空（例如只輸入 .jpg），報錯
if "!name!"=="" (
    echo 錯誤：檔名無效，請輸入有效檔名（例如: image.jpg）
    goto end
)

:: 如果檔案存在，避免覆蓋
set "finalname=!name!!ext!"
set /a n=1
:checkfile
if exist "!finalname!" (
    set "finalname=!name!_!n!!ext!"
    set /a n+=1
    goto checkfile
)

:: 執行下載
aria2c.exe -x 16 -s 10 -c --out="!finalname!" "%url%"

:end
echo.
pause
exit /b
