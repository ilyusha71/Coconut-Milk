@echo off
setlocal enabledelayedexpansion

:: �ˬd�O�_��J�F���
if "%~1"=="" (
    echo �бN .ts �����즹�}���W�i���ഫ�C
    pause
    exit /b
)

:: ��������|�B���W�]�L�X�i�W�^
set "input=%~1"
set "filename=%~n1"
set "output=%~dp1%filename%.mp4"

:: �ե� ffmpeg �i���ഫ
ffmpeg -i "%input%" -c copy "%output%"

echo.
echo �ഫ�����G%output%
pause
