@echo off
setlocal enabledelayedexpansion

echo �妸�ɩҦb��Ƨ��O�G%~dp0

where python >nul 2>nul || (
    echo �Х��w�� Python�I
    pause
    exit /b
)

if not exist "%~dp0fix_gbk_garbled.py" (
    echo �䤣�� Python �}�� "%~dp0fix_gbk_garbled.py"
    pause
    exit /b
)

if "%~1"=="" (
    echo �Щ즲�ɮר즹�妸�ɥH�״_�ýX
    pause
    exit /b
)

REM �N�妸�ɩҦb���|�s�ܼơA�קK�`�����ѪR���~
set "batdir=%~dp0"

:loop
if "%~1"=="" goto endloop

echo ���b�B�z�ɮסG%~1

REM �Χ妸�ɩҦb���|�I�s Python �}���A�Ѽƥ��ɮק�����|
python "%batdir%fix_gbk_garbled.py" "%~f1"

shift
goto loop

:endloop
echo �����B�z�����I
pause
