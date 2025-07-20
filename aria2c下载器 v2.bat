@echo off
setlocal disableDelayedExpansion
title aria2c下載器

:: 取得 bat 最後修改日期，格式轉為 yy-mm-dd
for /f "tokens=1 delims=." %%a in ("%~t0") do (
    set "rawdate=%%a"
)
set "rawdate=!rawdate:/=-!"
set "batdate=!rawdate:~2,2!-!rawdate:~5,2!-!rawdate:~8,2!"

:: 檢查 aria2c
where aria2c >nul 2>&1 || (
    echo 錯誤：請先安裝 aria2c
    pause
    exit /b
)

:start
cls
echo ========================================
echo aria2c下載器
echo 更新日期: !batdate!
echo 作者: 163	QQ: 2294147601
echo ========================================
echo.

:: 輸入連結
set /p url=請輸入下載連結：
if "%url%"=="" (
    echo 錯誤：未輸入任何連結！
    goto end
)

:: 輸入文件名
set /p filename=請輸入欲保存的文件名（含擴展名，留空則使用默認）：

:: 若留空則直接下載
if "%filename%"=="" (
    aria2c.exe -x 16 -s 10 -c "%url%"
    goto end
)

:: 檢查非法字元
echo %filename% | findstr /R "[\\/:*?\"<>|]" >nul
if not errorlevel 1 (
    echo 錯誤：文件名中包含非法字元！
    goto end
)

:: 啟用延遲展開（只在用到 ! 變數時）
setlocal enableDelayedExpansion

:: 拆分名稱與擴展名
for %%F in ("%filename%") do (
    set "name=%%~nF"
    set "ext=%%~xF"
)

:: 檢查文件主名是否為空（例如 .jpg）
if "!name!"=="" (
    echo 錯誤：文件名無效，請包含文件主名！
    goto end
)

set "outdir=%cd%\"
set "finalname=!name!!ext!"
set /a counter=1

:check_file_exists
if exist "!outdir!!finalname!" (
    set "finalname=!name!_!counter!!ext!"
    set /a counter+=1
    goto check_file_exists
)

:: 執行下載
aria2c.exe -x 16 -s 10 -c --out="!finalname!" "%url%"

:end
pause
