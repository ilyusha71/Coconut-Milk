@echo off
setlocal

:: ´ú¸Õ¤å¥ó
set "file=G:\g.˜Çº©\r­Y?¤å¤Æ\§¹?\d¤æ?¤Ñ¤U\ ç\¤æ?T¤U.S01EP20.2024.2160p.WEB-DL.HEVC.EDR.DDP2.0.mp4"

:: ©I¥s ffprobe ¨ú±o json ¿é¥X
ffprobe -v error -print_format json -show_format "%file%" > "%temp%\fmt.json"

:: Åã¥Ü®æ¦¡¸ê°T
echo.
echo ==== ¤å¥ó®æ¦¡¸ê°T ====
type "%temp%\fmt.json" | findstr /i /c:"format_name" /c:"format_long_name" /c:"tags"

echo.
echo ==== §PÂ_«Ê¸Ë®æ¦¡ ====

:: ³o¸Ì§Ú­Ì¥i¥H¨Ï¥ÎÂ²³æÅÞ¿è§PÂ_¬O§_¦³ mkv ¯S¼x
type "%temp%\fmt.json" | findstr /i /c:"matroska" >nul
if %errorlevel%==0 (
    echo [!] ¸Ó¤å¥ó¹ê»Ú«Ê¸Ë®æ¦¡¬° MKV (Matroska)
) else (
    echo [?] ¸Ó¤å¥óÀ³¬° MP4 ©Î¨ä¥L«D MKV «Ê¸Ë
)

echo.
pause
