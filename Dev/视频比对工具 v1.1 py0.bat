@echo off
setlocal enabledelayedexpansion
title ���W���u�� by 163

:: �ˬd Python �O�_�i��
where python >nul 2>&1 || (
    echo ���~�G�䤣�� python �Х��w�˨ó]�m�����ܶq
    pause
    exit /b
)

:: �ˬd ffprobe �O�_�i��
where ffprobe >nul 2>&1 || (
    echo ���~�G�䤣�� ffprobe �Х��w�� ffmpeg �ó]�m�����ܶq
    pause
    exit /b
)

if "%~2" neq "" (
    :: ����ӰѼơA�����ǵ� python �}��
    python "%~dp0probe_compare.py" "%~1" "%~2"
    pause
    exit /b
)

:: �L�ѼơA�椬��J
echo ==============================
echo ���W���u�� by 163
echo ==============================
echo.

set /p "file1=�Щ�J�Ĥ@�Ӥ��ο�J���|�G"
set "file1=%file1:"=%"
for %%A in ("%file1%") do set "file1=%%~fA"

if not exist "!file1!" (
    echo ���~�G�Ĥ@�Ӥ�󤣦s�b
    pause
    exit /b
)

set /p "file2=�Щ�J�ĤG�Ӥ��ο�J���|�G"
set "file2=%file2:"=%"
for %%A in ("%file2%") do set "file2=%%~fA"

if not exist "!file2!" (
    echo ���~�G�ĤG�Ӥ�󤣦s�b
    pause
    exit /b
)

python "%~dp0probe_compare.py" "!file1!" "!file2!"
pause
exit /b
