@echo off
setlocal
title �G���XŪ���u��

:: �ˬd�O�_���즲�Ϥ�
if "%~1"=="" (
    echo.
    echo �бN�G���X�Ϥ��즲�즹�ɮפW�C
    pause
    exit /b
)

:: ���� Python �}���A�î������~�X
python "%~dp0qr_read.py" "%~1"
if errorlevel 1 (
    echo.
    echo ? �o�Ϳ��~�A���ˬd�Ϥ��O�_�����Ī��G���X�Ϥ��C
    pause
)
