@echo off
setlocal enabledelayedexpansion
title 視頻比對工具

:: 取得真實 ESC 字元
for /F %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"

:: 取得 bat 最後修改日期，格式轉為 yy-mm-dd
for /f "tokens=1 delims=." %%a in ("%~t0") do (
    set "rawdate=%%a"
)
set "rawdate=!rawdate:/=-!"
set "batdate=!rawdate:~2,2!-!rawdate:~5,2!-!rawdate:~8,2!"

:: 檢查 ffmpeg
where ffmpeg >nul 2>&1 || (
    echo 錯誤：請先安裝 ffmpeg
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
echo 視頻比對工具
echo 更新日期: !batdate!
echo 作者: 163	QQ: 2294147601
echo ========================================
echo.
set /p "file1=請拖入第一個文件或輸入路徑："
set /p "file2=請拖入第二個文件或輸入路徑："

:: 去除輸入的雙引號
set "file1=%file1:"=%"
set "file2=%file2:"=%"

:: 絕對路徑轉換
for %%A in ("%file1%") do set "file1=%%~fA"
for %%A in ("%file2%") do set "file2=%%~fA"

if not exist "!file1!" (
    echo 錯誤：第一個文件不存在。
    pause
    exit /b
)
if not exist "!file2!" (
    echo 錯誤：第二個文件不存在。
    pause
    exit /b
)

:process_files

:: ============ 測試模塊：單次 ffprobe 調用 ==================
echo.
echo ============ [測試] 單次 ffprobe 抓取所有信息 =============

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
echo [測試] TestSingleProbe 兩次調用總耗時： %total_duration% 毫秒
echo.


echo ==============================================================

echo.開始比對以下兩個文件：
echo [1] !file1!
echo [2] !file2!

:: 文件大小計算
for /f %%A in ('powershell -NoProfile -Command "[math]::Round((Get-Item -LiteralPath '%file1%').Length / 1MB, 2)"') do set "mb1=%%A"
for /f %%A in ('powershell -NoProfile -Command "[math]::Round((Get-Item -LiteralPath '%file2%').Length / 1MB, 2)"') do set "mb2=%%A"

:: 取得 file1 擴展名
for %%A in ("!file1!") do set "ext1=%%~xA"
for %%A in ("!file2!") do set "ext2=%%~xA"

:: 封裝容器分類
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
echo [計時] 封裝容器分類兩次調用總耗時： %total_duration% 毫秒
echo.

:: 時長計算
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
echo [計時] 時長計算兩次調用總耗時： %total_duration% 毫秒
echo.


:: 碼率計算
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
echo [計時] 碼率計算兩次調用總耗時： %total_duration% 毫秒
echo.


:: 視頻編碼標準化
call :NormalizeCodec "!codec1!" codec1
call :NormalizeCodec "!codec2!" codec2

:: 幀率計算
call :CalcFPS "!frate1!" fps1
call :CalcFPS "!frate2!" fps2

:: 分辨率
set "res1=!width1! x !height1!"
set "res2=!width2! x !height2!"

:: 色彩深度
call :GetBitDepth "!pixfmt1!" depth1
call :GetBitDepth "!pixfmt2!" depth2

:: 音頻編碼標準化（可後續補完）
call :NormalizeCodec "!acodec1!" acodec1
call :NormalizeCodec "!acodec2!" acodec2

:: 音頻碼率（同樣處理為 kbps）
call :GetBitrateFromRaw "!abr1!" "!dur1!" "!file1!" kabr1
call :GetBitrateFromRaw "!abr2!" "!dur2!" "!file2!" kabr2


:: ================= 顯示結果 =================
echo.
echo =============================== 比 對 結 果 ==================
call :printLine "大小　　　　　" "!mb1! MB" "!mb2! MB"
call :printLine "封裝格式　　　" "!fmt1!" "!fmt2!"
call :printLine "時長　　　　　" "!fdur1!" "!fdur2!"
echo ================================== 視 頻 =====================
call :printLine "視頻編碼　　　" "!codec1!" "!codec2!"
call :printLine "視頻碼率　　　" "!kvbr1! kbps" "!kvbr2! kbps"
call :printLine "分辨率　　　　" "!res1!" "!res2!"
call :printLine "幀率　　　　　" "!fps1!" "!fps2!"
call :printLine "色彩深度　　　" "!depth1!" "!depth2!"
echo ================================== 音 頻 =====================
call :printLine "音頻編碼　　　" "!acodec1!" "!acodec2!"
call :printLine "音頻碼率　　　" "!kabr1! kbps" "!kabr2! kbps"
call :printLine "聲道　　　　　" "!alayout1!" "!alayout2!"
call :printLine "採樣率　　　　" "!asamplerate1! Hz" "!asamplerate2! Hz"

echo ==============================================================

echo 更新日期：!batdate!
echo 踩雷先鋒：163
echo 扣扣　　：2294147601
echo ==============================================================
echo.
pause
exit /b

:: ======================= 輔助函式區 =========================

::高亮標記
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

::表格設定
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

::取得格式
:: 根據 brand 判斷主格式為 mp4 或 mov
:: 綜合 format_name 與 brand 判斷主格式（mp4, mov, mkv, avi...）
:GetMainFormat
setlocal enabledelayedexpansion
set "fmt_name=%~1"
set "brand=%~2"
set "ext=%~3"
set "mainfmt=unknown"

:: 1. 預設先以副檔名為主格式（可信度中等）
if /i "%ext%"==".mkv" set "mainfmt=mkv"
if /i "%ext%"==".webm" set "mainfmt=webm"
if /i "%ext%"==".mp4" set "mainfmt=mp4"
if /i "%ext%"==".mov" set "mainfmt=mov"
if /i "%ext%"==".avi" set "mainfmt=avi"
if /i "%ext%"==".flv" set "mainfmt=flv"

:: 2. 用 format_name 判斷，如果與副檔名衝突，保留原判斷
set "fmt_guess="
echo !fmt_name! | findstr /i "avi"   >nul && set "fmt_guess=avi"
echo !fmt_name! | findstr /i "mkv"   >nul && set "fmt_guess=mkv"
echo !fmt_name! | findstr /i "flv"   >nul && set "fmt_guess=flv"
echo !fmt_name! | findstr /i "webm"  >nul && set "fmt_guess=webm"
echo !fmt_name! | findstr /i "mp4"   >nul && set "fmt_guess=mp4"
echo !fmt_name! | findstr /i "mov"   >nul && set "fmt_guess=mov"

:: 如果 format_name 結果與副檔名不同，保留副檔名（不覆蓋）
if defined fmt_guess (
    if /i not "!mainfmt!"=="!fmt_guess!" (
        rem echo 衝突：副檔名=!mainfmt! / format_name=!fmt_guess!（保留副檔名）
    ) else (
        set "mainfmt=!fmt_guess!"
    )
)

:: 3. 最後用 brand 判斷 mp4/mov，可信度最高，直接覆蓋
echo !brand! | findstr /i "qt"  >nul && set "mainfmt=mov"
echo !brand! | findstr /i "mp4" >nul && set "mainfmt=mp4"

endlocal & set "%~4=%mainfmt%"
goto :eof







::標準化時長
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

::計算碼率
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

::格式標準化
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

::分析色深
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

::計算幀率
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


:: 取得當前時間的毫秒數（0~86400000）
:GetTimeMS
rem 取得當前時間（格式 HH:mm:ss.xx 或 HH:mm:ss.xxx）
setlocal enabledelayedexpansion
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set /a hh=%%a, mm=%%b, ss=%%c, cc=%%d
)
set /a ms=hh*3600000 + mm*60000 + ss*1000 + cc
endlocal & set "timeMS=%ms%"
goto :eof









::使用ffprobe獲取所有參數
:TestSingleProbe
setlocal enabledelayedexpansion

:: 記錄開始時間
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

echo --- 文件[%idx%]：!file! ---

if not exist "!file!" (
    echo [錯誤] 找不到文件: !file!
    goto :eof
)

:: 抓 format_name 和 duration
set "format_tmpfile=%TEMP%\format_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -show_entries format=format_name,duration -of default=noprint_wrappers=1:nokey=0 "!file!" > "!format_tmpfile!" 2>nul"

:: 抓 brand（compatible_brands）
set "brand_tmpfile=%TEMP%\brand_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -show_entries format_tags=compatible_brands -of default=noprint_wrappers=1:nokey=1 "!file!" > "!brand_tmpfile!" 2>nul"

:: 抓 video stream
set "video_tmpfile=%TEMP%\video_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -select_streams v:0 -show_entries stream=index,codec_name,codec_type,width,height,bit_rate,avg_frame_rate,pix_fmt -of default=noprint_wrappers=1:nokey=0 "!file!" > "!video_tmpfile!" 2>nul"

:: 抓 audio stream
set "audio_tmpfile=%TEMP%\audio_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -select_streams a:0 -show_entries stream=index,codec_name,codec_type,bit_rate,channels,sample_rate,channel_layout -of default=noprint_wrappers=1:nokey=0 "!file!" > "!audio_tmpfile!" 2>nul"

:: 等待所有 tmpfile 完成
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
        echo [錯誤] 等待 ffprobe 超時
        goto :eof
    )
   timeout /t 1 >nul
    goto wait_all_tmpfiles
)

:: 初始化變量
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

:: 讀取 format
for /f "usebackq tokens=1,* delims==" %%A in ("!format_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if /i "!key!"=="format_name" set "fmt_full=!val!"
    if /i "!key!"=="duration" set "duration=!val!"
)

:: 讀取 brand
for /f "usebackq delims=" %%B in ("!brand_tmpfile!") do (
    set "brand=%%B"
)

:: 讀取 video stream
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

:: 讀取 audio stream
for /f "usebackq tokens=1,* delims==" %%A in ("!audio_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if "!key!"=="codec_name" set "acodec=!val!"
    if "!key!"=="bit_rate" set "abr=!val!"
    if "!key!"=="channels" set "achannels=!val!"
    if "!key!"=="sample_rate" set "asamplerate=!val!"
    if "!key!"=="channel_layout" set "alayout=!val!"
)

:: 刪除暫存檔
if exist "!format_tmpfile!" del /f /q "!format_tmpfile!" >nul 2>nul
if exist "!brand_tmpfile!" del /f /q "!brand_tmpfile!" >nul 2>nul
if exist "!video_tmpfile!" del /f /q "!video_tmpfile!" >nul 2>nul
if exist "!audio_tmpfile!" del /f /q "!audio_tmpfile!" >nul 2>nul

:: 記錄結束時間
set "end_time=%TIME%"

:: 計算耗時
call :TimeDiff "%start_time%" "%end_time%" elapsed_ms
echo [測試] TestSingleProbe 文件[%idx%] 執行時間： %elapsed_ms% 毫秒

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

:: 計算時間差，返回毫秒
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

:: 如果變量為空則賦0
for %%x in (sh sm ss sc eh em es ec) do (
    if "!%%x!"=="" set "%%x=0"
)

:: 確保都是數字，去除前導空格
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
::使用ffprobe獲取所有參數
:TestSingleProbe
setlocal enabledelayedexpansion

:: 記錄開始時間，使用延遲擴展讀取時間變量
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

echo --- 文件[%idx%]：!file! ---

if not exist "!file!" (
    echo [錯誤] 找不到文件: !file!
    goto :eof
)

:: 抓 format_name 和 duration
set "format_tmpfile=%TEMP%\format_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -show_entries format=format_name,duration -of default=noprint_wrappers=1:nokey=0 "!file!" > "!format_tmpfile!" 2>nul"

:: 抓 brand（compatible_brands）
set "brand_tmpfile=%TEMP%\brand_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -show_entries format_tags=compatible_brands -of default=noprint_wrappers=1:nokey=1 "!file!" > "!brand_tmpfile!" 2>nul"

:: 抓 video stream
set "video_tmpfile=%TEMP%\video_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -select_streams v:0 -show_entries stream=index,codec_name,codec_type,width,height,bit_rate,avg_frame_rate,pix_fmt -of default=noprint_wrappers=1:nokey=0 "!file!" > "!video_tmpfile!" 2>nul"

:: 抓 audio stream
set "audio_tmpfile=%TEMP%\audio_!uid!.tmp"
start "" /b cmd /c "ffprobe -v error -select_streams a:0 -show_entries stream=index,codec_name,codec_type,bit_rate,channels,sample_rate,channel_layout -of default=noprint_wrappers=1:nokey=0 "!file!" > "!audio_tmpfile!" 2>nul"

:: 等待所有 tmpfile 完成
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
        echo [錯誤] 等待 ffprobe 超時
        goto :eof
    )
    timeout /t 1 >nul
    goto wait_all_tmpfiles
)

:: 初始化變量
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

:: 讀取 format
for /f "usebackq tokens=1,* delims==" %%A in ("!format_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if /i "!key!"=="format_name" set "fmt_full=!val!"
    if /i "!key!"=="duration" set "duration=!val!"
)

:: 讀取 brand
for /f "usebackq delims=" %%B in ("!brand_tmpfile!") do (
    set "brand=%%B"
)

:: 讀取 video stream
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

:: 讀取 audio stream
for /f "usebackq tokens=1,* delims==" %%A in ("!audio_tmpfile!") do (
    set "key=%%A"
    set "val=%%B"
    if "!key!"=="codec_name" set "acodec=!val!"
    if "!key!"=="bit_rate" set "abr=!val!"
    if "!key!"=="channels" set "achannels=!val!"
    if "!key!"=="sample_rate" set "asamplerate=!val!"
    if "!key!"=="channel_layout" set "alayout=!val!"
)

:: 刪除暫存檔
if exist "!format_tmpfile!" del /f /q "!format_tmpfile!" >nul 2>nul
if exist "!brand_tmpfile!" del /f /q "!brand_tmpfile!" >nul 2>nul
if exist "!video_tmpfile!" del /f /q "!video_tmpfile!" >nul 2>nul
if exist "!audio_tmpfile!" del /f /q "!audio_tmpfile!" >nul 2>nul

:: 記錄結束時間
call :GetNowTime end_time

:: 計算耗時，調用帶 enabledelayedexpansion 的 TimeDiff
call :TimeDiff "!start_time!" "!end_time!" elapsed_ms
echo [測試] TestSingleProbe 文件[%idx%] 執行時間： %elapsed_ms% 毫秒

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


:: 用 PowerShell 獲取當前時間（帶毫秒三位）
:GetNowTime
for /f "delims=" %%t in ('powershell -NoProfile -Command "Get-Date -Format 'HH:mm:ss.fff'"') do (
    set "%~1=%%t"
)
goto :eof

:: 計算時間差，返回毫秒（不換行，適用於 bat）
:TimeDiff
setlocal
set "start=%~1"
set "end=%~2"

for /f "delims=" %%i in ('powershell -NoProfile -Command "try { $start=[datetime]::Parse('%start%'); $end=[datetime]::Parse('%end%'); if ($end -lt $start) { $end = $end.AddDays(1) }; [math]::Round(($end - $start).TotalMilliseconds) } catch { -1 }"') do set diff=%%i

endlocal & set "%~3=%diff%"
goto :eof
