@echo off
setlocal enabledelayedexpansion
title µøÀWÂàGIF¤u¨ã

echo.
echo ========================================
echo       µøÀW ¡÷ °ÊºAGIF Âà´«¤u¨ã
echo ========================================
echo.

:: ¨ú±o¤å¥ó¸ô®|
set "videofile=%~1"
if "%videofile%"=="" (
    set /p videofile=½Ð¿é¤JµøÀW¤å¥ó¸ô®|©Î©ì¤J¡G
)

:: ²¾°£¥i¯à¦h§E¤Þ­¡]Á×§KÈ­«¤Þ­¡^
set "videofile=%videofile:"=%"

:: ÀË¬d¬O§_¦s¦b
if not exist "%videofile%" (
    echo ¿ù»~¡G§ä¤£¨ì¸Ó¤å¥ó¡I
    pause > nul
    exit /b 1
)

:: ©I¥s Python ¸}¥»
python "%~dp0video_to_gif_byWindow.py" "%videofile%"
if errorlevel 1 (
    echo.
    echo ¿ù»~¡GPython ¸}¥»°õ¦æ¥¢±Ñ¡A½ÐÀË¬d Python Àô¹Ò¤Î¸}¥»¡C
) else (
    echo.
    echo Âà´«§¹¦¨¡I
)

pause > nul
exit /b
