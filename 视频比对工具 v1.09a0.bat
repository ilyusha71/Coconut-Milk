@echo off
setlocal enabledelayedexpansion
title ���W���u��

:: ���o�u�� ESC �r��
for /F %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"

:: ���o bat �̫�ק����A�榡�ର yy-mm-dd
for /f "tokens=1 delims=." %%a in ("%~t0") do (
    set "rawdate=%%a"
)
set "rawdate=!rawdate:/=-!"
set "batdate=!rawdate:~2,2!-!rawdate:~5,2!-!rawdate:~8,2!"

:: �ˬd ffmpeg
where ffmpeg >nul 2>&1 || (
    echo ���~�G�Х��w�� ffmpeg
    pause
    exit /b
)

if not "%~2"=="" (
    set "file1=%~1"
    set "file2=%~2"
    goto :process_files
)

:wait_for_input
echo ========================================
echo ���W���u��
echo ��s���: !batdate!
echo �@��: 163	QQ: 2294147601
echo ========================================
echo.
set /p "file1=�Щ�J�Ĥ@�Ӥ��ο�J���|�G"
set /p "file2=�Щ�J�ĤG�Ӥ��ο�J���|�G"

:: �h����J�����޸�
set "file1=%file1:"=%"
set "file2=%file2:"=%"

:: ������|�ഫ
for %%A in ("%file1%") do set "file1=%%~fA"
for %%A in ("%file2%") do set "file2=%%~fA"

if not exist "!file1!" (
    echo ���~�G�Ĥ@�Ӥ�󤣦s�b�C
    pause
    exit /b
)
if not exist "!file2!" (
    echo ���~�G�ĤG�Ӥ�󤣦s�b�C
    pause
    exit /b
)

:process_files

:: ============ ���ռҶ��G�榸 ffprobe �ե� ==================
echo.
echo ============ [����] �榸 ffprobe ����Ҧ��H�� =============

call :TestSingleProbe "!file1!" 1
call :TestSingleProbe "!file2!" 2

echo ==============================================================

echo.�}�l���H�U��Ӥ��G
echo [1] !file1!
echo [2] !file2!

:: ���j�p�p��
for /f %%A in ('powershell -NoProfile -Command "[math]::Round((Get-Item -LiteralPath '%file1%').Length / 1MB, 2)"') do set "mb1=%%A"
for /f %%A in ('powershell -NoProfile -Command "[math]::Round((Get-Item -LiteralPath '%file2%').Length / 1MB, 2)"') do set "mb2=%%A"

:: ���o file1 �X�i�W
for %%A in ("!file1!") do set "ext1=%%~xA"
for %%A in ("!file2!") do set "ext2=%%~xA"

:: �ʸˮe������
call :GetMainFormat "!fmt1_full!" "!brand1!" "!ext1!" fmt1
call :GetMainFormat "!fmt2_full!" "!brand2!" "!ext2!" fmt2

:: �ɪ��p��
call :FormatTime !dur1! fdur1
call :FormatTime !dur2! fdur2

:: �X�v�p��
call :GetBitrateFromRaw "!vbr1!" "!dur1!" "!file1!" kvbr1
call :GetBitrateFromRaw "!vbr2!" "!dur2!" "!file2!" kvbr2

:: ���W�s�X�зǤ�
call :NormalizeCodec "!codec1!" codec1
call :NormalizeCodec "!codec2!" codec2

:: �V�v�p��
call :CalcFPS "!frate1!" fps1
call :CalcFPS "!frate2!" fps2

:: ����v
set "res1=!width1! x !height1!"
set "res2=!width2! x !height2!"

:: ��m�`��
call :GetBitDepth "!pixfmt1!" depth1
call :GetBitDepth "!pixfmt2!" depth2

:: ���W�s�X�зǤơ]�i����ɧ��^
call :NormalizeCodec "!acodec1!" acodec1
call :NormalizeCodec "!acodec2!" acodec2

:: ���W�X�v�]�P�˳B�z�� kbps�^
call :GetBitrateFromRaw "!abr1!" "!dur1!" "!file1!" kabr1
call :GetBitrateFromRaw "!abr2!" "!dur2!" "!file2!" kabr2


:: ================= ��ܵ��G =================
echo.
echo =============================== �� �� �� �G ==================
call :printLine "�j�p�@�@�@�@�@" "!mb1! MB" "!mb2! MB"
call :printLine "�ʸˮ榡�@�@�@" "!fmt1!" "!fmt2!"
call :printLine "�ɪ��@�@�@�@�@" "!fdur1!" "!fdur2!"
call :printLine "���W�X�v�@�@�@" "!kvbr1! kbps" "!kvbr2! kbps"
call :printLine "���W�s�X�@�@�@" "!codec1!" "!codec2!"
call :printLine "�V�v�@�@�@�@�@" "!fps1!" "!fps2!"
call :printLine "����v�@�@�@�@" "!res1!" "!res2!"
call :printLine "��m�`�ס@�@�@" "!depth1!" "!depth2!"
call :printLine "���W�s�X�@�@�@" "!acodec1!" "!acodec2!"
call :printLine "���W�X�v�@�@�@" "!kabr1! kbps" "!kabr2! kbps"
call :printLine "�n�D�@�@�@�@�@" "!alayout1!" "!alayout2!"
call :printLine "�ļ˲v�@�@�@�@" "!asamplerate1! Hz" "!asamplerate2! Hz"

echo ==============================================================

echo ��s����G!batdate!
echo ��p���W�G163
echo �����@�@�G2294147601
echo ==============================================================
echo.
pause
exit /b

:: ======================= ���U�禡�� =========================

::���G�аO
:EchoColor
setlocal enabledelayedexpansion
set "color=%~1"
set "text=%~2"
if /i "%color%"=="green" (
    set "col=%ESC%[92m"
) else if /i "%color%"=="blue" (
    set "col=%ESC%[96m"
) else if /i "%color%"=="yellow" (
    set "col=%ESC%[93m"
) else (
    set "col=%ESC%[0m"
)
<nul set /p= !col!!text!!%ESC%[0m
endlocal & goto :eof

::���]�w
:printLine
set "label=%~1"
set "left=%~2"
set "right=%~3"
set "col1Width=16"
set "col2Width=20"
set "col3Width=20"
call :padRight labelPadded " %label% " %col1Width%
call :padRight leftPadded "%left%" %col2Width%
call :padRight rightPadded "%right%" %col3Width%
<nul set /p= %label%^| 
call :EchoColor green " !leftPadded!"
<nul set /p= ^| 
call :EchoColor blue " !rightPadded!"
echo.
goto :eof

:padRight
set "str=%~2"
set "len=0"
:len_loop
if defined str (
    set "str=!str:~1!"
    set /a len+=1
    goto len_loop
)
set /a need=%~3 - len
if %need% LSS 0 set need=0
set "spaces=                                        "
set "pad=!spaces:~0,%need%!"
set "%~1=%~2%pad%"
goto :eof

::���o�榡
:: �ھ� brand �P�_�D�榡�� mp4 �� mov
:: ��X format_name �P brand �P�_�D�榡�]mp4, mov, mkv, avi...�^
:GetMainFormat
setlocal enabledelayedexpansion
set "fmt_name=%~1"
set "brand=%~2"
set "ext=%~3"
set "mainfmt=unknown"

:: 1. �w�]���H���ɦW���D�榡�]�i�H�פ����^
if /i "%ext%"==".mkv" set "mainfmt=mkv"
if /i "%ext%"==".webm" set "mainfmt=webm"
if /i "%ext%"==".mp4" set "mainfmt=mp4"
if /i "%ext%"==".mov" set "mainfmt=mov"
if /i "%ext%"==".avi" set "mainfmt=avi"
if /i "%ext%"==".flv" set "mainfmt=flv"

:: 2. �� format_name �P�_�A�p�G�P���ɦW�Ĭ�A�O�d��P�_
set "fmt_guess="
echo !fmt_name! | findstr /i "avi"   >nul && set "fmt_guess=avi"
echo !fmt_name! | findstr /i "mkv"   >nul && set "fmt_guess=mkv"
echo !fmt_name! | findstr /i "flv"   >nul && set "fmt_guess=flv"
echo !fmt_name! | findstr /i "webm"  >nul && set "fmt_guess=webm"
echo !fmt_name! | findstr /i "mp4"   >nul && set "fmt_guess=mp4"
echo !fmt_name! | findstr /i "mov"   >nul && set "fmt_guess=mov"

:: �p�G format_name ���G�P���ɦW���P�A�O�d���ɦW�]���л\�^
if defined fmt_guess (
    if /i not "!mainfmt!"=="!fmt_guess!" (
        rem echo �Ĭ�G���ɦW=!mainfmt! / format_name=!fmt_guess!�]�O�d���ɦW�^
    ) else (
        set "mainfmt=!fmt_guess!"
    )
)

:: 3. �̫�� brand �P�_ mp4/mov�A�i�H�׳̰��A�����л\
echo !brand! | findstr /i "qt"  >nul && set "mainfmt=mov"
echo !brand! | findstr /i "mp4" >nul && set "mainfmt=mp4"

endlocal & set "%~4=%mainfmt%"
goto :eof







::�зǤƮɪ�
:FormatTime
set "duration=%~1"
for /f "tokens=1 delims=." %%a in ("!duration!") do set sec_int=%%a
set "dec=00"
for /f "tokens=2 delims=." %%b in ("!duration!") do (
    set "dec=%%b"
    if "!dec:~1,1!"=="" set "dec=!dec!0"
    set "dec=!dec:~0,2!"
)
set /a hh=sec_int/3600
set /a mm=(sec_int %% 3600)/60
set /a ss=sec_int %% 60
if %hh% lss 10 set hh=0%hh%
if %mm% lss 10 set mm=0%mm%
if %ss% lss 10 set ss=0%ss%
set "%2=%hh%:%mm%:%ss%.%dec%"
goto :eof

::�p��X�v
:GetBitrateFromRaw
setlocal enabledelayedexpansion
set "vbr_raw=%~1"
set "duration=%~2"
set "filepath=%~3"
set "kbps="
set "estimate_flag="
for /f "delims=0123456789" %%c in ("!vbr_raw!") do (
    set "vbr_raw=0"
)
if not defined vbr_raw set "vbr_raw=0"
if "!vbr_raw!"=="0" (
    for %%f in ("!filepath!") do set "fsize=%%~zf"
    for /f "tokens=1 delims=." %%t in ("!duration!") do set "seconds=%%t"
    if defined seconds if not "!seconds!"=="0" (
        for /f %%k in ('powershell -NoProfile -Command "Write-Output ([math]::Round((!fsize! * 8.0 / 1024.0 / !seconds!),0))"') do (
            set "kbps_est=%%k"
        )
        set "estimate_flag=~"
        set "kbps=!estimate_flag!!kbps_est!"
    ) else (
        set "kbps=N/A"
    )
) else (
    set /a kbps = vbr_raw / 1000
)
if not defined kbps set "kbps=N/A"
endlocal & set "%~4=%kbps%"
goto :eof

::�榡�зǤ�
:NormalizeCodec
setlocal
set "input=%~1"
set "out="
if /i "%input%"=="h264" set "out=AVC (H.264)"
if /i "%input%"=="hevc" set "out=HEVC (H.265)"
if /i "%input%"=="mpeg4" set "out=MPEG-4"
if /i "%input%"=="vp9" set "out=VP9"
if /i "%input%"=="av1" set "out=AV1"
if /i "%input%"=="wmv3" set "out=WMV3"
if /i "%input%"=="vc1" set "out=VC-1"
if not defined out set "out=%input%"
endlocal & set "%~2=%out%"
goto :eof

::���R��`
:GetBitDepth
setlocal enabledelayedexpansion
set "pixfmt=%~1"
set "bitdepth=unknown"
if defined pixfmt (
    echo !pixfmt! | findstr /i "10" >nul && set "bitdepth=10"
    echo !pixfmt! | findstr /i "12" >nul && set "bitdepth=12"
    echo !pixfmt! | findstr /i "16" >nul && set "bitdepth=16"
    if "!bitdepth!"=="unknown" set "bitdepth=8"
)
if defined pixfmt (
    if "!bitdepth!"=="unknown" (
        set "result=!pixfmt!"
    ) else (
        set "result=!pixfmt! !bitdepth!bit"
    )
) else (
    set "result=N/A"
)
endlocal & set "%~2=%result%"
goto :eof

::�p��V�v
:CalcFPS
setlocal enabledelayedexpansion
set "frac=%~1"
if "!frac!"=="" set "frac=0/1"
for /f "tokens=1,2 delims=/" %%a in ("!frac!") do (
 set "num=%%a"
 set "den=%%b"
)
if not defined num set "num=0"
if not defined den set "den=1"
for /f "delims=0123456789" %%x in ("!num!") do set "num=0"
for /f "delims=0123456789" %%x in ("!den!") do set "den=1"
if "!den!"=="0" set "den=1"
for /f %%f in ('powershell -NoProfile -Command "[math]::Round(%num% / %den%, 3)"') do set "fps=%%f"
endlocal & set "%2=%fps% fps"
goto :eof






::�ϥ�ffprobe����Ҧ��Ѽ�
:TestSingleProbe
setlocal enabledelayedexpansion
set "file=%~1"
set "idx=%~2"
set "uid=%idx%_%RANDOM%"
set "fmt_full="
set "duration="
set "bit_rate="
set "codec_name="
set "width="
set "height="
set "avg_frame_rate="
set "pix_fmt="
set "brand="

echo --- ���[%idx%]�G!file! ---

if not exist "!file!" (
    echo [���~] �䤣����: !file!
    goto :eof
)

:: �� format �� format_name �M duration
set "format_tmpfile=%TEMP%\format_tmpfile_!uid!.tmp"
ffprobe -v error -show_entries format=format_name,duration -of default=noprint_wrappers=1:nokey=0 "!file!" > "!format_tmpfile!" 2>nul

:: ��l���ܶq
set "fmt_full="
set "duration="
set "brand=N/A"

:: Ū�� format_name �M duration
for /f "usebackq tokens=1,* delims==" %%A in ("!format_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if /i "!key!"=="format_name" set "fmt_full=!val!"
    if /i "!key!"=="duration" set "duration=!val!"
)
if defined format_tmpfile (
    if exist "!format_tmpfile!" del /f /q "!format_tmpfile!" >nul 2>nul
)

:: ��W�� compatible_brands�]��μȦs�ɤ覡�^
set "brand_tmpfile=%TEMP%\brand_tmpfile_!uid!.tmp"
ffprobe -v error -show_entries format_tags=compatible_brands -of default=noprint_wrappers=1:nokey=1 "!file!" > "!brand_tmpfile!" 2>nul

for /f "usebackq delims=" %%B in ("!brand_tmpfile!") do (
    set "brand=%%B"
)
if defined brand_tmpfile (
    if exist "!brand_tmpfile!" del /f /q "!brand_tmpfile!" >nul 2>nul
)

:: �� stream
set "tmpfile=%TEMP%\ffmeta_!uid!.tmp"
if exist "!tmpfile!" del /f /q "!tmpfile!" >nul 2>nul

ffprobe -v error -select_streams v:0 -show_entries stream=index,codec_name,codec_type,width,height,bit_rate,avg_frame_rate,pix_fmt -of default=noprint_wrappers=1:nokey=0 "!file!" > "!tmpfile!" 2>nul
for /f "usebackq tokens=1,* delims==" %%A in ("!tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if "!key!"=="bit_rate" set "bit_rate=!val!"
    if "!key!"=="codec_name" set "codec_name=!val!"
    if "!key!"=="width" set "width=!val!"
    if "!key!"=="height" set "height=!val!"
    if "!key!"=="avg_frame_rate" set "avg_frame_rate=!val!"
    if "!key!"=="pix_fmt" set "pix_fmt=!val!"
)
if not defined fmt_full set "fmt_full=N/A"
if not defined duration set "duration=0"
if not defined bit_rate set "bit_rate=0"
if not defined codec_name set "codec_name=N/A"
if not defined width set "width=0"
if not defined height set "height=0"
if not defined avg_frame_rate set "avg_frame_rate=0/1"
if not defined pix_fmt set "pix_fmt=N/A"
if not defined brand set "brand=N/A"

echo �榡: !fmt_full!
echo �ɪ�: !duration!
echo �X�v: !bit_rate!
echo �s�X: !codec_name!
echo ����v: !width!x!height!
echo �V�v: !avg_frame_rate!
echo ��`(pix_fmt): !pix_fmt!
echo �~�P����: !brand!
if defined tmpfile (
    echo "!tmpfile!" | findstr /i "ffmeta_" >nul
    if not errorlevel 1 (
        if exist "!tmpfile!" del /f /q "!tmpfile!" >nul 2>nul
    )
)

:: �� audio stream
set "atmpfile=%TEMP%\ffmeta_audio_!uid!.tmp"
if exist "!atmpfile!" del /f /q "!atmpfile!" >nul 2>nul

ffprobe -v error -select_streams a:0 -show_entries stream=index,codec_name,codec_type,bit_rate,channels,sample_rate,channel_layout -of default=noprint_wrappers=1:nokey=0 "!file!" > "!atmpfile!" 2>nul
for /f "usebackq tokens=1,* delims==" %%A in ("!atmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if "!key!"=="codec_name" set "acodec=!val!"
    if "!key!"=="bit_rate" set "abr=!val!"
    if "!key!"=="channels" set "achannels=!val!"
    if "!key!"=="sample_rate" set "asamplerate=!val!"
    if "!key!"=="channel_layout" set "alayout=!val!"
)
if not defined acodec set "acodec=N/A"
if not defined abr set "abr=0"
if not defined achannels set "achannels=0"
if not defined asamplerate set "asamplerate=N/A"
if not defined alayout set "alayout=N/A"

echo ���W�s�X: !acodec!
echo ���W�X�v: !abr!
echo �n�D�ƶq: !achannels!
echo �ļ˲v�@: !asamplerate!
echo �n�D�ƦC: !alayout!
if defined atmpfile (
    echo "!atmpfile!" | findstr /i "ffmeta_audio_" >nul
    if not errorlevel 1 (
        if exist "!atmpfile!" del /f /q "!atmpfile!" >nul 2>nul
    )
)

endlocal & (
    set "fmt%idx%_full=%fmt_full%"
    set "dur%idx%=%duration%"
    set "vbr%idx%=%bit_rate%"
    set "codec%idx%=%codec_name%"
    set "width%idx%=%width%"
    set "height%idx%=%height%"
    set "frate%idx%=%avg_frame_rate%"
    set "pixfmt%idx%=%pix_fmt%"
    set "brand%idx%=%brand%"
    set "acodec%idx%=%acodec%"
    set "abr%idx%=%abr%"
    set "achannels%idx%=%achannels%"
    set "asamplerate%idx%=%asamplerate%"
    set "alayout%idx%=%alayout%"
)
goto :eof
