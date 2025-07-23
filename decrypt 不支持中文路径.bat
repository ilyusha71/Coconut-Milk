@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

if "%~1"=="" (
    echo 請將加密的 .mp4/.m4s 文件拖入本批處理文件！
    pause
    exit /b
)

set "INPUT=%~1"
set "OUTPUT=%~dpn1_dec%~x1"

echo.
echo ? 輸入文件：%INPUT%
echo ? 輸出文件：%OUTPUT%
echo.

set /p KEYSTR=請輸入 KID:KEY（例如：abcd...:1122...）： 
echo.

if not exist "mp4decrypt.exe" (
    echo ? 找不到 mp4decrypt.exe，請確認它和本批處理文件在同一資料夾
    pause
    exit /b
)

echo ? 正在解密...

:: 不使用短路?，直接使用原始路??行
mp4decrypt.exe --key %KEYSTR% "%INPUT%" "%OUTPUT%"

set ERR=%ERRORLEVEL%

echo.
if %ERR% equ 0 (
    if exist "%OUTPUT%" (
        echo ? 解密完成！已輸出：%OUTPUT%
    ) else (
        echo ? 解密完成，但未產生輸出文件，請檢查 KEY 是否正確
    )
) else (
    echo ? 解密過程出錯，錯誤碼：%ERR%
)

pause
