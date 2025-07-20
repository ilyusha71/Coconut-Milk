@echo off
setlocal

rem �M�����դ��
del /f /q "%TEMP%\file1.tmp" >nul 2>&1
del /f /q "%TEMP%\file2.tmp" >nul 2>&1
del /f /q "%TEMP%\file3.tmp" >nul 2>&1
del /f /q "%TEMP%\file4.tmp" >nul 2>&1

rem �O���}�l�ɶ��]�@��^
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do set /a "start=(((%%a*60)+1%%b%%100)*60+1%%c%%100)*100+1%%d%%100"

rem �Ұ�4�Ӽ����Ӯɥ��ȡA�C�ӥ��ȵ���2��A�M��g�@�Ӥ��
start "" /b cmd /c "timeout /t 2 >nul & echo done1 > %TEMP%\file1.tmp"
start "" /b cmd /c "timeout /t 2 >nul & echo done2 > %TEMP%\file2.tmp"
start "" /b cmd /c "timeout /t 2 >nul & echo done3 > %TEMP%\file3.tmp"
start "" /b cmd /c "timeout /t 2 >nul & echo done4 > %TEMP%\file4.tmp"

rem ����4�Ӥ������ͦ�
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

rem �O�������ɶ�
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do set /a "end=(((%%a*60)+1%%b%%100)*60+1%%c%%100)*100+1%%d%%100"

rem �p��Ӯɡ]�@��^
set /a duration=end-start
if %duration% lss 0 set /a duration+=24*60*60*100

echo 4�Өæ�����`�Ӯ�: %duration% �@��

rem �R���{�ɤ��
del /f /q "%TEMP%\file1.tmp" "%TEMP%\file2.tmp" "%TEMP%\file3.tmp" "%TEMP%\file4.tmp" >nul 2>&1

endlocal
pause
