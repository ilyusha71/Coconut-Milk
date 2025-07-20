@echo off
setlocal disableDelayedExpansion
title aria2c�U����

:: ���o bat �̫�ק����A�榡�ର yy-mm-dd
for /f "tokens=1 delims=." %%a in ("%~t0") do (
    set "rawdate=%%a"
)
set "rawdate=!rawdate:/=-!"
set "batdate=!rawdate:~2,2!-!rawdate:~5,2!-!rawdate:~8,2!"

:: �ˬd aria2c
where aria2c >nul 2>&1 || (
    echo ���~�G�Х��w�� aria2c
    pause
    exit /b
)

:start
cls
echo ========================================
echo aria2c�U����
echo ��s���: !batdate!
echo �@��: 163	QQ: 2294147601
echo ========================================
echo.

:: ��J�s��
set /p url=�п�J�U���s���G
if "%url%"=="" (
    echo ���~�G����J����s���I
    goto end
)

:: ��J���W
set /p filename=�п�J���O�s�����W�]�t�X�i�W�A�d�ūh�ϥ��q�{�^�G

:: �Y�d�ūh�����U��
if "%filename%"=="" (
    aria2c.exe -x 16 -s 10 -c "%url%"
    goto end
)

:: �ˬd�D�k�r��
echo %filename% | findstr /R "[\\/:*?\"<>|]" >nul
if not errorlevel 1 (
    echo ���~�G���W���]�t�D�k�r���I
    goto end
)

:: �ҥΩ���i�}�]�u�b�Ψ� ! �ܼƮɡ^
setlocal enableDelayedExpansion

:: ����W�ٻP�X�i�W
for %%F in ("%filename%") do (
    set "name=%%~nF"
    set "ext=%%~xF"
)

:: �ˬd���D�W�O�_���š]�Ҧp .jpg�^
if "!name!"=="" (
    echo ���~�G���W�L�ġA�Х]�t���D�W�I
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

:: ����U��
aria2c.exe -x 16 -s 10 -c --out="!finalname!" "%url%"

:end
pause
