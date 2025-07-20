@echo off
setlocal enabledelayedexpansion
title ���W�ʭ��B�z�u��

REM �ˬd�O�_��J�ɮ�
if "%~1"=="" (
    echo �бN MP4 �ɮש�J���妸�ɡC
    pause
    exit /b
)

set "videoFile=%~1"
set "baseName=%~dpn1"
set "extName=%~x1"

echo.
echo �B�z���v���ɡG%videoFile%
echo.

echo ��ܾާ@�G
echo 1. �K�[�ʭ��]�L�ʭ��ɥΡ^
echo 2. �󴫫ʭ�
echo 3. �����ʭ�
echo 4. �R���ʭ�
set /p choice=�п�J�Ʀr�ë��U Enter�G

if "%choice%"=="1" goto :add_cover
if "%choice%"=="2" goto :replace_cover
if "%choice%"=="3" goto :extract_cover
if "%choice%"=="4" goto :remove_cover

echo �L�Ŀﶵ�C
pause
exit /b

:add_cover
call :select_image
if not exist "!imgFile!" (
    echo �䤣��Ϥ��ɮסC
    pause
    exit /b
)
ffmpeg -i "%videoFile%" -i "!imgFile!" -map 0 -map 1 -c copy ^
    -metadata:s:v:1 title="Album cover" -metadata:s:v:1 comment="Cover (front)" -disposition:v:1 attached_pic ^
    "%baseName%_�K�[�ʭ�%extName%" -y
echo �ʭ��w�K�[�C
pause
exit /b

:replace_cover
call :select_image
if not exist "!imgFile!" (
    echo �䤣��Ϥ��ɮסC
    pause
    exit /b
)
echo ���b�󴫫ʭ�...

REM ������ʭ�
ffmpeg -i "%videoFile%" -map 0 -map -0:v:1 -c copy "temp_no_cover%extName%" -y

REM �N�Ϥ��ର jpg
ffmpeg -i "!imgFile!" -frames:v 1 -q:v 2 "temp_cover.jpg" -y

REM �K�[�s�ʭ�
ffmpeg -i "temp_no_cover%extName%" -i "temp_cover.jpg" -map 0 -map 1 -c copy ^
    -metadata:s:v:1 title="Album cover" -metadata:s:v:1 comment="Cover (front)" -disposition:v:1 attached_pic ^
    "%baseName%_�󴫫ʭ�%extName%" -y

REM �M�z�{����
del "temp_no_cover%extName%" >nul 2>&1
del "temp_cover.jpg" >nul 2>&1

echo �ʭ��w�󴫦��\�C
pause
exit /b

:extract_cover
ffmpeg -i "%videoFile%" -an -vcodec copy "%baseName%_�ʭ�.jpg" -y
echo �ʭ��w�������G%baseName%_�ʭ�.jpg
pause
exit /b

:remove_cover
ffmpeg -i "%videoFile%" -map 0 -map -0:v:1 -c copy "%baseName%_�L�ʭ�%extName%" -y
echo �ʭ��w�R���C
pause
exit /b

:select_image
echo �бN�ʭ��Ϥ��ɩ�J�������A�M��� Enter�G
set /p imgFile=
set imgFile=%imgFile:"=%
exit /b
