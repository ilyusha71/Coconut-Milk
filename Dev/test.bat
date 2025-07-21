@echo off
setlocal

rem 清除測試文件
del /f /q "%TEMP%\file1.tmp" >nul 2>&1
del /f /q "%TEMP%\file2.tmp" >nul 2>&1
del /f /q "%TEMP%\file3.tmp" >nul 2>&1
del /f /q "%TEMP%\file4.tmp" >nul 2>&1

rem 記錄開始時間（毫秒）
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do set /a "start=(((%%a*60)+1%%b%%100)*60+1%%c%%100)*100+1%%d%%100"

rem 啟動4個模擬耗時任務，每個任務等待2秒，然後寫一個文件
start "" /b cmd /c "timeout /t 2 >nul & echo done1 > %TEMP%\file1.tmp"
start "" /b cmd /c "timeout /t 2 >nul & echo done2 > %TEMP%\file2.tmp"
start "" /b cmd /c "timeout /t 2 >nul & echo done3 > %TEMP%\file3.tmp"
start "" /b cmd /c "timeout /t 2 >nul & echo done4 > %TEMP%\file4.tmp"

rem 等待4個文件全部生成
:waitloop
set "_ready=1"
if not exist "%TEMP%\file1.tmp" set "_ready=0"
if not exist "%TEMP%\file2.tmp" set "_ready=0"
if not exist "%TEMP%\file3.tmp" set "_ready=0"
if not exist "%TEMP%\file4.tmp" set "_ready=0"

if %_ready%==0 (
    timeout /t 0 >nul
    goto waitloop
)

rem 記錄結束時間
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do set /a "end=(((%%a*60)+1%%b%%100)*60+1%%c%%100)*100+1%%d%%100"

rem 計算耗時（毫秒）
set /a duration=end-start
if %duration% lss 0 set /a duration+=24*60*60*100

echo 4個並行任務總耗時: %duration% 毫秒

rem 刪除臨時文件
del /f /q "%TEMP%\file1.tmp" "%TEMP%\file2.tmp" "%TEMP%\file3.tmp" "%TEMP%\file4.tmp" >nul 2>&1

endlocal
pause
