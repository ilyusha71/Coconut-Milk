@echo off
setlocal enabledelayedexpansion
title ���W��GIF�u��

echo.
echo ========================================
echo       ���W �� �ʺAGIF �ഫ�u��
echo ========================================
echo.

:: ���o�����|
set "videofile=%~1"
if "%videofile%"=="" (
    set /p videofile=�п�J���W�����|�Ω�J�G
)

:: �����i��h�E�ޏ��]�קK�ȭ��ޏ��^
set "videofile=%videofile:"=%"

:: �ˬd�O�_�s�b
if not exist "%videofile%" (
    echo ���~�G�䤣��Ӥ��I
    pause > nul
    exit /b 1
)

:: �I�s Python �}��
python "%~dp0video_to_gif_byWindow.py" "%videofile%"
if errorlevel 1 (
    echo.
    echo ���~�GPython �}�����楢�ѡA���ˬd Python ���Ҥθ}���C
) else (
    echo.
    echo �ഫ�����I
)

pause > nul
exit /b
