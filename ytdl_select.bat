@echo off
setlocal enabledelayedexpansion
title YouTube �h�u�{�U����

echo ===========================================
echo     YouTube �h�u�{�U���� (yt-dlp + aria2c)
echo         �䴩�e���ܡB�v���X��
echo ===========================================

set /p url=�жK�W YouTube �v���s���G

if "%url%"=="" (
    echo ���~�G����J�s���I
    pause
    exit /b 1
)

echo.
echo �i�i�εe��M��j
yt-dlp.exe -F "%url%"
echo.

set /p fmt=�п�J�Q�n�U�����榡�N���]�i���u137+140�v�榡�^�G

if "%fmt%"=="" (
    echo ���~�G����J�榡�N���I
    pause
    exit /b 1
)

echo.
echo �}�l�U���榡 %fmt% ���v���P���T...
yt-dlp.exe -f %fmt% --merge-output-format mp4 ^
 --external-downloader aria2c ^
 --external-downloader-args "-x 16 -s 10 -c" "%url%"

echo.
echo �U�������I
pause
