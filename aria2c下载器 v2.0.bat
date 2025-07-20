@echo off
setlocal enabledelayedexpansion
title aria2c ²���U����

:: ��J�s��
set /p url=�п�J�U���s���G
if "%url%"=="" (
    echo ���~�G����J�s��
    goto end
)

:: ��J�ۭq�ɦW�]�i�d�š^
set /p filename=�п�J�O�s�ɦW�]�t���ɦW�A�i�d�š^�G

:: �p�G����J�ɦW�A�����ιw�]�W�٤U��
if "%filename%"=="" (
    aria2c.exe -x 16 -s 10 -c "%url%"
    goto end
)

:: ��Ѱ��ɦW
for %%F in ("%filename%") do (
    set "name=%%~nF"
    set "ext=%%~xF"
)

:: �Y�D�W���š]�Ҧp�u��J .jpg�^�A����
if "!name!"=="" (
    echo ���~�G�ɦW�L�ġA�п�J�����ɦW�]�Ҧp: image.jpg�^
    goto end
)

:: �p�G�ɮצs�b�A�קK�л\
set "finalname=!name!!ext!"
set /a n=1
:checkfile
if exist "!finalname!" (
    set "finalname=!name!_!n!!ext!"
    set /a n+=1
    goto checkfile
)

:: ����U��
aria2c.exe -x 16 -s 10 -c --out="!finalname!" "%url%"

:end
echo.
pause
exit /b
