@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

if "%~1"=="" (
    echo �бN�[�K�� .mp4/.m4s ����J����B�z���I
    pause
    exit /b
)

set "INPUT=%~1"
set "OUTPUT=%~dpn1_dec%~x1"

echo.
echo ? ��J���G%INPUT%
echo ? ��X���G%OUTPUT%
echo.

set /p KEYSTR=�п�J KID:KEY�]�Ҧp�Gabcd...:1122...�^�G 
echo.

if not exist "mp4decrypt.exe" (
    echo ? �䤣�� mp4decrypt.exe�A�нT�{���M����B�z���b�P�@��Ƨ�
    pause
    exit /b
)

echo ? ���b�ѱK...

:: ���ϥεu��?�A�����ϥέ�l��??��
mp4decrypt.exe --key %KEYSTR% "%INPUT%" "%OUTPUT%"

set ERR=%ERRORLEVEL%

echo.
if %ERR% equ 0 (
    if exist "%OUTPUT%" (
        echo ? �ѱK�����I�w��X�G%OUTPUT%
    ) else (
        echo ? �ѱK�����A�������Ϳ�X���A���ˬd KEY �O�_���T
    )
) else (
    echo ? �ѱK�L�{�X���A���~�X�G%ERR%
)

pause
