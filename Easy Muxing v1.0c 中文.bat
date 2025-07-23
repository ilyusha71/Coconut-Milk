@echo off
setlocal enabledelayedexpansion
title �����W�X�}�u��

:: ���o bat �̫�ק����A�榡�ର yy-mm-dd
for /f "tokens=1 delims=." %%a in ("%~t0") do (
    set "rawdate=%%a"
)
set "rawdate=!rawdate:/=-!"
set "batdate=!rawdate:~2,2!-!rawdate:~5,2!-!rawdate:~8,2!"

REM Check if two files were dragged in �ˬd�O�_��J����ɮ�
if "%~2"=="" (
    echo Please drag both video and audio files onto this batch file.
    echo �бN���W�P���W���@�֩�J��B�z�C
    pause
    exit /b
)

REM Get basic info of the two files ���o����T
for %%F in ("%~1") do (
    set "file1=%%~fF"
    set "name1=%%~nxF"
    set "ext1=%%~xF"
    set "size1=%%~zF"
)
for %%F in ("%~2") do (
    set "file2=%%~fF"
    set "name2=%%~nxF"
    set "ext2=%%~xF"
    set "size2=%%~zF"
)

REM Compare file sizes to determine which is video ������j�p
if !size1! GTR !size2! (
    set "video=!file1!"
    set "audio=!file2!"
    set "v_name=!name1!"
    set "v_ext=!ext1!"
    set "v_size=!size1!"
    set "a_name=!name2!"
    set "a_ext=!ext2!"
    set "a_size=!size2!"
) else (
    set "video=!file2!"
    set "audio=!file1!"
    set "v_name=!name2!"
    set "v_ext=!ext2!"
    set "v_size=!size2!"
    set "a_name=!name1!"
    set "a_ext=!ext1!"
    set "a_size=!size1!"
)

REM Get video duration
for /f "tokens=2 delims= " %%a in ('ffmpeg -i "!video!" 2^>^&1 ^| findstr "Duration"') do (
    set "v_duration=%%a"
)

REM Get audio duration
for /f "tokens=2 delims= " %%a in ('ffmpeg -i "!audio!" 2^>^&1 ^| findstr "Duration"') do (
    set "a_duration=%%a"
)

REM Remove trailing commas
set "v_duration=!v_duration:,=!"
set "a_duration=!a_duration:,=!"

REM Check if video has internal audio
ffmpeg -i "!video!" 2>&1 | findstr "Audio:" >nul
if !errorlevel! == 0 (
    set "has_internal_audio=true"
) else (
    set "has_internal_audio=false"
)

REM Display info
echo ----------------------------------------
echo �����W�X�֤u�� v1.2
echo ��s���: !batdate!
echo �@��: 163	QQ: 2294147601)
echo ----------------------------------------
echo [Video Info] ���W��T
echo File Name  : !v_name!
echo Path       : !video!
echo Extension  : !v_ext!
echo Size       : !v_size! bytes  ~ !v_size:~0,-6!.!v_size:~-6,1! MB
echo Duration   : !v_duration!
echo Has Audio  : !has_internal_audio!
echo.
echo [Audio Info] ���W��T
echo File Name  : !a_name!
echo Path       : !audio!
echo Extension  : !a_ext!
echo Size       : !a_size! bytes  ~ !a_size:~0,-6!.!a_size:~-6,1! MB
echo Duration   : !a_duration!
echo ----------------------------------------

echo.
echo Press Enter to start merging...
echo �нT�{�W�C���L�~����U Enter ��H�~��X��...
pause >nul

REM Set output filename
set "basename=!v_name!"
set "basename=!basename:~0,-4!"
set "output=!basename!_merged.mp4"

REM Merge based on whether internal audio exists
if "!has_internal_audio!"=="true" (
    ffmpeg -i "!video!" -i "!audio!" -map 0:v:0 -map 1:a:0 -map 0:a:0 -c copy -disposition:a:0 default -disposition:a:1 none "!output!"
) else (
    ffmpeg -i "!video!" -i "!audio!" -c copy "!output!"
)

echo.
echo Done. Output file: !output!
echo �X�֧���
pause
