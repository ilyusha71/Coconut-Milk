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

call :GetTimeMS
set "start1=%timeMS%"
call :TestSingleProbe "!file1!" 1
call :GetTimeMS
set "end1=%timeMS%"
set /a duration1=end1 - start1
if %duration1% lss 0 set /a duration1+=86400000

call :GetTimeMS
set "start2=%timeMS%"
call :TestSingleProbe "!file2!" 2
call :GetTimeMS
set "end2=%timeMS%"
set /a duration2=end2 - start2
if %duration2% lss 0 set /a duration2+=86400000

set /a total_duration=duration1 + duration2

echo.
echo [����] TestSingleProbe �⦸�ե��`�ӮɡG %total_duration% �@��
echo.


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
call :GetTimeMS
set "start1=%timeMS%"
call :GetMainFormat "!fmt1_full!" "!brand1!" "!ext1!" fmt1
call :GetTimeMS
set "end1=%timeMS%"
set /a duration1=end1 - start1
if %duration1% lss 0 set /a duration1+=86400000

call :GetTimeMS
set "start2=%timeMS%"
call :GetMainFormat "!fmt2_full!" "!brand2!" "!ext2!" fmt2
call :GetTimeMS
set "end2=%timeMS%"
set /a duration2=end2 - start2
if %duration2% lss 0 set /a duration2+=86400000

set /a total_duration=duration1 + duration2

echo.
echo [�p��] �ʸˮe�������⦸�ե��`�ӮɡG %total_duration% �@��
echo.

:: �ɪ��p��
call :GetTimeMS
set "start1=%timeMS%"
call :FormatTime !dur1! fdur1
call :GetTimeMS
set "end1=%timeMS%"
set /a duration1=end1 - start1
if %duration1% lss 0 set /a duration1+=86400000

call :GetTimeMS
set "start2=%timeMS%"
call :FormatTime !dur2! fdur2
call :GetTimeMS
set "end2=%timeMS%"
set /a duration2=end2 - start2
if %duration2% lss 0 set /a duration2+=86400000

set /a total_duration=duration1 + duration2

echo.
echo [�p��] �ɪ��p��⦸�ե��`�ӮɡG %total_duration% �@��
echo.


:: �X�v�p��
call :GetTimeMS
set "start1=%timeMS%"
call :GetBitrateFromRaw "!vbr1!" "!dur1!" "!file1!" kvbr1
call :GetTimeMS
set "end1=%timeMS%"
set /a duration1=end1 - start1
if %duration1% lss 0 set /a duration1+=86400000

call :GetTimeMS
set "start2=%timeMS%"
call :GetBitrateFromRaw "!vbr2!" "!dur2!" "!file2!" kvbr2
call :GetTimeMS
set "end2=%timeMS%"
set /a duration2=end2 - start2
if %duration2% lss 0 set /a duration2+=86400000

set /a total_duration=duration1 + duration2

echo.
echo [�p��] �X�v�p��⦸�ե��`�ӮɡG %total_duration% �@��
echo.


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
echo ================================== �� �W =====================
call :printLine "���W�s�X�@�@�@" "!codec1!" "!codec2!"
call :printLine "���W�X�v�@�@�@" "!kvbr1! kbps" "!kvbr2! kbps"
call :printLine "����v�@�@�@�@" "!res1!" "!res2!"
call :printLine "�V�v�@�@�@�@�@" "!fps1!" "!fps2!"
call :printLine "��m�`�ס@�@�@" "!depth1!" "!depth2!"
echo ================================== �� �W =====================
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


:: ���o��e�ɶ����@��ơ]0~86400000�^
:GetTimeMS
rem ���o��e�ɶ��]�榡 HH:mm:ss.xx �� HH:mm:ss.xxx�^
setlocal enabledelayedexpansion
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set /a hh=%%a, mm=%%b, ss=%%c, cc=%%d
)
set /a ms=hh*3600000 + mm*60000 + ss*1000 + cc
endlocal & set "timeMS=%ms%"
goto :eof









::�ϥ�ffprobe����Ҧ��Ѽ�
:TestSingleProbe
setlocal enabledelayedexpansion

:: �O���}�l�ɶ�
set "start_time=%TIME%"

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

:: �� format_name �M duration
set "format_tmpfile=%TEMP%\format_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -show_entries format=format_name,duration -of default=noprint_wrappers=1:nokey=0 "!file!" > "!format_tmpfile!" 2>nul"

:: �� brand�]compatible_brands�^
set "brand_tmpfile=%TEMP%\brand_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -show_entries format_tags=compatible_brands -of default=noprint_wrappers=1:nokey=1 "!file!" > "!brand_tmpfile!" 2>nul"

:: �� video stream
set "video_tmpfile=%TEMP%\video_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -select_streams v:0 -show_entries stream=index,codec_name,codec_type,width,height,bit_rate,avg_frame_rate,pix_fmt -of default=noprint_wrappers=1:nokey=0 "!file!" > "!video_tmpfile!" 2>nul"

:: �� audio stream
set "audio_tmpfile=%TEMP%\audio_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -select_streams a:0 -show_entries stream=index,codec_name,codec_type,bit_rate,channels,sample_rate,channel_layout -of default=noprint_wrappers=1:nokey=0 "!file!" > "!audio_tmpfile!" 2>nul"

:: ���ݩҦ� tmpfile ����
set /a _waitcount=0
:wait_all_tmpfiles
set /a _ready=1
if not exist "!format_tmpfile!" set /a _ready=0
if not exist "!brand_tmpfile!" set /a _ready=0
if not exist "!video_tmpfile!" set /a _ready=0
if not exist "!audio_tmpfile!" set /a _ready=0
if !_ready! EQU 0 (
    set /a _waitcount+=1
    if !_waitcount! GEQ 100 (
        echo [���~] ���� ffprobe �W��
        goto :eof
    )
   timeout /t 1 >nul
    goto wait_all_tmpfiles
)

:: ��l���ܶq
set "fmt_full="
set "duration="
set "brand=N/A"
set "bit_rate=0"
set "codec_name=N/A"
set "width=0"
set "height=0"
set "avg_frame_rate=0/1"
set "pix_fmt=N/A"
set "acodec=N/A"
set "abr=0"
set "achannels=0"
set "asamplerate=N/A"
set "alayout=N/A"

:: Ū�� format
for /f "usebackq tokens=1,* delims==" %%A in ("!format_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if /i "!key!"=="format_name" set "fmt_full=!val!"
    if /i "!key!"=="duration" set "duration=!val!"
)

:: Ū�� brand
for /f "usebackq delims=" %%B in ("!brand_tmpfile!") do (
    set "brand=%%B"
)

:: Ū�� video stream
for /f "usebackq tokens=1,* delims==" %%A in ("!video_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if "!key!"=="bit_rate" set "bit_rate=!val!"
    if "!key!"=="codec_name" set "codec_name=!val!"
    if "!key!"=="width" set "width=!val!"
    if "!key!"=="height" set "height=!val!"
    if "!key!"=="avg_frame_rate" set "avg_frame_rate=!val!"
    if "!key!"=="pix_fmt" set "pix_fmt=!val!"
)

:: Ū�� audio stream
for /f "usebackq tokens=1,* delims==" %%A in ("!audio_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if "!key!"=="codec_name" set "acodec=!val!"
    if "!key!"=="bit_rate" set "abr=!val!"
    if "!key!"=="channels" set "achannels=!val!"
    if "!key!"=="sample_rate" set "asamplerate=!val!"
    if "!key!"=="channel_layout" set "alayout=!val!"
)

:: �R���Ȧs��
if exist "!format_tmpfile!" del /f /q "!format_tmpfile!" >nul 2>nul
if exist "!brand_tmpfile!" del /f /q "!brand_tmpfile!" >nul 2>nul
if exist "!video_tmpfile!" del /f /q "!video_tmpfile!" >nul 2>nul
if exist "!audio_tmpfile!" del /f /q "!audio_tmpfile!" >nul 2>nul

:: �O�������ɶ�
set "end_time=%TIME%"

:: �p��Ӯ�
call :TimeDiff "%start_time%" "%end_time%" elapsed_ms
echo [����] TestSingleProbe ���[%idx%] ����ɶ��G %elapsed_ms% �@��

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

:: �p��ɶ��t�A��^�@��
:TimeDiff
setlocal
set "start=%~1"
set "end=%~2"

echo start_time=%start%
echo end_time=%end%


for /f "tokens=1-4 delims=:." %%a in ("%start%") do (
    set "sh=%%a"
    set "sm=%%b"
    set "ss=%%c"
    set "sc=%%d"
)
for /f "tokens=1-4 delims=:." %%a in ("%end%") do (
    set "eh=%%a"
    set "em=%%b"
    set "es=%%c"
    set "ec=%%d"
)

:: �p�G�ܶq���ūh��0
for %%x in (sh sm ss sc eh em es ec) do (
    if "!%%x!"=="" set "%%x=0"
)

:: �T�O���O�Ʀr�A�h���e�ɪŮ�
set /a sh=1!sh!-100
set /a sm=1!sm!-100
set /a ss=1!ss!-100
set /a sc=1!sc!-100
set /a eh=1!eh!-100
set /a em=1!em!-100
set /a es=1!es!-100
set /a ec=1!ec!-100

set /a start_ms=((sh*3600+sm*60+ss)*1000+sc*10)
set /a end_ms=((eh*3600+em*60+es)*1000+ec*10)

if %end_ms% LSS %start_ms% set /a end_ms+=86400000
set /a diff=end_ms - start_ms

endlocal & set "%~3=%diff%"
goto :eof
::�ϥ�ffprobe����Ҧ��Ѽ�
:TestSingleProbe
setlocal enabledelayedexpansion

:: �O���}�l�ɶ��A�ϥΩ����X�iŪ���ɶ��ܶq
call :GetNowTime start_time

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

:: �� format_name �M duration
set "format_tmpfile=%TEMP%\format_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -show_entries format=format_name,duration -of default=noprint_wrappers=1:nokey=0 "!file!" > "!format_tmpfile!" 2>nul"

:: �� brand�]compatible_brands�^
set "brand_tmpfile=%TEMP%\brand_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -show_entries format_tags=compatible_brands -of default=noprint_wrappers=1:nokey=1 "!file!" > "!brand_tmpfile!" 2>nul"

:: �� video stream
set "video_tmpfile=%TEMP%\video_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -select_streams v:0 -show_entries stream=index,codec_name,codec_type,width,height,bit_rate,avg_frame_rate,pix_fmt -of default=noprint_wrappers=1:nokey=0 "!file!" > "!video_tmpfile!" 2>nul"

:: �� audio stream
set "audio_tmpfile=%TEMP%\audio_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -select_streams a:0 -show_entries stream=index,codec_name,codec_type,bit_rate,channels,sample_rate,channel_layout -of default=noprint_wrappers=1:nokey=0 "!file!" > "!audio_tmpfile!" 2>nul"

:: ���ݩҦ� tmpfile ����
set /a _waitcount=0
:wait_all_tmpfiles
set /a _ready=1
if not exist "!format_tmpfile!" set /a _ready=0
if not exist "!brand_tmpfile!" set /a _ready=0
if not exist "!video_tmpfile!" set /a _ready=0
if not exist "!audio_tmpfile!" set /a _ready=0
if !_ready! EQU 0 (
    set /a _waitcount+=1
    if !_waitcount! GEQ 100 (
        echo [���~] ���� ffprobe �W��
        goto :eof
    )
    timeout /t 1 >nul
    goto wait_all_tmpfiles
)

:: ��l���ܶq
set "fmt_full="
set "duration="
set "brand=N/A"
set "bit_rate=0"
set "codec_name=N/A"
set "width=0"
set "height=0"
set "avg_frame_rate=0/1"
set "pix_fmt=N/A"
set "acodec=N/A"
set "abr=0"
set "achannels=0"
set "asamplerate=N/A"
set "alayout=N/A"

:: Ū�� format
for /f "usebackq tokens=1,* delims==" %%A in ("!format_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if /i "!key!"=="format_name" set "fmt_full=!val!"
    if /i "!key!"=="duration" set "duration=!val!"
)

:: Ū�� brand
for /f "usebackq delims=" %%B in ("!brand_tmpfile!") do (
    set "brand=%%B"
)

:: Ū�� video stream
for /f "usebackq tokens=1,* delims==" %%A in ("!video_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if "!key!"=="bit_rate" set "bit_rate=!val!"
    if "!key!"=="codec_name" set "codec_name=!val!"
    if "!key!"=="width" set "width=!val!"
    if "!key!"=="height" set "height=!val!"
    if "!key!"=="avg_frame_rate" set "avg_frame_rate=!val!"
    if "!key!"=="pix_fmt" set "pix_fmt=!val!"
)

:: Ū�� audio stream
for /f "usebackq tokens=1,* delims==" %%A in ("!audio_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if "!key!"=="codec_name" set "acodec=!val!"
    if "!key!"=="bit_rate" set "abr=!val!"
    if "!key!"=="channels" set "achannels=!val!"
    if "!key!"=="sample_rate" set "asamplerate=!val!"
    if "!key!"=="channel_layout" set "alayout=!val!"
)

:: �R���Ȧs��
if exist "!format_tmpfile!" del /f /q "!format_tmpfile!" >nul 2>nul
if exist "!brand_tmpfile!" del /f /q "!brand_tmpfile!" >nul 2>nul
if exist "!video_tmpfile!" del /f /q "!video_tmpfile!" >nul 2>nul
if exist "!audio_tmpfile!" del /f /q "!audio_tmpfile!" >nul 2>nul

:: �O�������ɶ�
call :GetNowTime end_time

:: �p��ӮɡA�եαa enabledelayedexpansion �� TimeDiff
call :TimeDiff "!start_time!" "!end_time!" elapsed_ms
echo [����] TestSingleProbe ���[%idx%] ����ɶ��G %elapsed_ms% �@��

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


:: �� PowerShell �����e�ɶ��]�a�@��T��^
:GetNowTime
for /f "delims=" %%t in ('powershell -NoProfile -Command "Get-Date -Format 'HH:mm:ss.fff'"') do (
    set "%~1=%%t"
)
goto :eof

:: �p��ɶ��t�A��^�@��]������A�A�Ω� bat�^
:TimeDiff
setlocal
set "start=%~1"
set "end=%~2"

for /f "delims=" %%i in ('powershell -NoProfile -Command "try { $start=[datetime]::Parse('%start%'); $end=[datetime]::Parse('%end%'); if ($end -lt $start) { $end = $end.AddDays(1) }; [math]::Round(($end - $start).TotalMilliseconds) } catch { -1 }"') do set diff=%%i

endlocal & set "%~3=%diff%"
goto :eof
