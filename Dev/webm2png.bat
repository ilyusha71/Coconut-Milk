@echo off
setlocal enabledelayedexpansion

echo.
echo �i�i�i WebP �Ϥ��� PNG�]���Ĥ@�V�^�i�i�i
echo ----------------------------------

:: �ˬd�O�_��J���
if "%~1"=="" (
    echo �бN .webp ���즲�ܥ��妸���H�ഫ�� PNG�C
    pause
    exit /b
)

:: �B�z�C�ө�J�����
for %%F in (%*) do (
    set "filepath=%%~fF"
    set "ext=%%~xF"
    set "name=%%~nF"
    set "folder=%%~dpF"

    if /i "!ext!"==".webp" (
        echo �B�z�G!name!!ext!

        set "outpath=!folder!!name!.png"

        :: �����Ĥ@�V�� PNG�]�L�l�^
        ffmpeg -y -v error -i "!filepath!" -vframes 1 -vsync 0 "!outpath!"

        if exist "!outpath!" (
            echo �� �w��X�G!outpath!
        ) else (
            echo �� �ഫ���ѡI
        )
        echo.
    ) else (
        echo [���L] ���O .webp ���G%%~nxF
    )
)

echo �ഫ�����C
pause
