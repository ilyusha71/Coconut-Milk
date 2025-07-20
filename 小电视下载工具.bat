@echo off
setlocal
Title �p�q���U���u��

:: ���o bat �̫�ק����A�榡�ର yy-mm-dd
for /f "tokens=1 delims=." %%a in ("%~t0") do (
    set "rawdate=%%a"
)
set "rawdate=!rawdate:/=-!"
set "batdate=!rawdate:~2,2!-!rawdate:~5,2!-!rawdate:~8,2!"

:: �ˬd aria2c
where aria2c >nul 2>&1 || (
    echo ���~�G�Х��w�� aria2c
    pause
    exit /b
)

:: �ˬd ffmpeg
where ffmpeg >nul 2>&1 || (
    echo ���~�G�Х��w�� ffmpeg
    pause
    exit /b
)

:start
cls
echo ================================
echo          �p�q���U���u��
echo ��s���: !batdate!
echo �@��: 163	QQ: 2294147601
echo ========================================
echo.

:: ���и߰ݵ��W���}
:AskVideo
set /p video_url=�п�J���W URL: 
if "%video_url%"=="" (
    echo [���~] ������J���W URL�I
    goto AskVideo
)

:: ���и߰ݭ��T���}
:AskAudio
set /p audio_url=�п�J���W URL: 
if "%audio_url%"=="" (
    echo [���~] ������J���W URL�I
    goto AskAudio
)

:: ���W�]�i�š^
set /p title=�п�J���W�]���t�X�i�W�A�d�Ŧ۰ʩR�W�^: 
if "%title%"=="" (
    for /f %%a in ('powershell -nologo -command "[guid]::NewGuid().ToString()"') do (
        set "title=%%a"
    )
)
:: �T�O title �Q���T�]�������ܼơ]�קK����i�}���D�^
call set "title=%title%"
echo [����] �w�۰ʥͦ����W�G%title%.mp4

:: Referer �]�w�]�i�šA�w�]N�^
set /p use_ref=�O�_�[�J Referer�]Y/N�A�w�]��N�^: 
if "%use_ref%"=="" set use_ref=N

set "ref="
if /i "%use_ref%"=="Y" (
    set "ref=--referer=https://www.bilibili.com/"
)

:: ���ͼȦs�� UUID
for /f %%a in ('powershell -command "[guid]::NewGuid().ToString()"') do set v_uuid=%%a
for /f %%a in ('powershell -command "[guid]::NewGuid().ToString()"') do set a_uuid=%%a

:: �U�����W
echo ���b�U�����W...
aria2c -x 16 -s 10 -c -o %v_uuid%.m4s %ref% "%video_url%"
if errorlevel 1 (
    echo ���W�U�����ѡI
    pause
    exit /b
)

:: �U�����W
echo ���b�U�����W...
aria2c -x 16 -s 10 -c -o %a_uuid%.m4s %ref% "%audio_url%"
if errorlevel 1 (
    echo ���W�U�����ѡI
    pause
    exit /b
)

:: �X��
echo ���b�X�ֵ��W�P���W...
ffmpeg -i %v_uuid%.m4s -i %a_uuid%.m4s -c copy "%title%.mp4" -y
if errorlevel 1 (
    echo �X�֥��ѡI
    pause
    exit /b
)

:: �R���Ȧs���]�w���^
if defined v_uuid if exist "%v_uuid%.m4s" del /f /q "%v_uuid%.m4s"
if defined a_uuid if exist "%a_uuid%.m4s" del /f /q "%a_uuid%.m4s"

echo �����I��X��󬰡G%title%.mp4

:: ���񴣥ܭ�
powershell -c "(New-Object Media.SoundPlayer 'C:\Windows\Media\Windows Notify Calendar.wav').PlaySync()"

:: ��ܳq��
powershell -Command "& { [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null; $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02); $textNodes = $template.GetElementsByTagName('text'); $textNodes.Item(0).AppendChild($template.CreateTextNode('�U������')) > $null; $textNodes.Item(1).AppendChild($template.CreateTextNode('�w���\���� %title%.mp4')) > $null; $toast = [Windows.UI.Notifications.ToastNotification]::new($template); $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('�p�q���U���u��'); $notifier.Show($toast) }"

pause
