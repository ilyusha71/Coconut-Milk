@echo off
setlocal enabledelayedexpansion

REM �ˬd�O�_��J���
if "%~1"=="" (
    echo �бN�@�ӵ��W���즲�즹bat���W�B��C
    pause
    exit /b
)

REM ���o��l���H��
set "input=%~1"
set "filename=%~n1"
set "ext=%~x1"

REM �]�w��X���W��
set "output=%~dp1%filename% 4K�W�M.mp4"

REM �ϥ�ffmpeg�ƻs���T�P���T�y�A�ȲM�� title �P comment metadata
ffmpeg -i "%input%" -c:v copy -c:a copy -metadata title= -metadata comment= -movflags +faststart "%output%"

echo.
echo �ഫ�����I

:: ���񴣥ܭ��]���ѫװ��^
powershell -c "(New-Object Media.SoundPlayer 'C:\Windows\Media\Windows Notify Calendar.wav').PlaySync()"

pause
