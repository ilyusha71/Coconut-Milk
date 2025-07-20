@echo off
setlocal
Title 小電視下載工具

:: 取得 bat 最後修改日期，格式轉為 yy-mm-dd
for /f "tokens=1 delims=." %%a in ("%~t0") do (
    set "rawdate=%%a"
)
set "rawdate=!rawdate:/=-!"
set "batdate=!rawdate:~2,2!-!rawdate:~5,2!-!rawdate:~8,2!"

:: 檢查 aria2c
where aria2c >nul 2>&1 || (
    echo 錯誤：請先安裝 aria2c
    pause
    exit /b
)

:: 檢查 ffmpeg
where ffmpeg >nul 2>&1 || (
    echo 錯誤：請先安裝 ffmpeg
    pause
    exit /b
)

:start
cls
echo ================================
echo          小電視下載工具
echo 更新日期: !batdate!
echo 作者: 163	QQ: 2294147601
echo ========================================
echo.

:: 反覆詢問視頻網址
:AskVideo
set /p video_url=請輸入視頻 URL: 
if "%video_url%"=="" (
    echo [錯誤] 必須輸入視頻 URL！
    goto AskVideo
)

:: 反覆詢問音?網址
:AskAudio
set /p audio_url=請輸入音頻 URL: 
if "%audio_url%"=="" (
    echo [錯誤] 必須輸入音頻 URL！
    goto AskAudio
)

:: 文件名（可空）
set /p title=請輸入文件名（不含擴展名，留空自動命名）: 
if "%title%"=="" (
    for /f %%a in ('powershell -nologo -command "[guid]::NewGuid().ToString()"') do (
        set "title=%%a"
    )
)
:: 確保 title 被正確設為環境變數（避免延遲展開問題）
call set "title=%title%"
echo [提示] 已自動生成文件名：%title%.mp4

:: Referer 設定（可空，預設N）
set /p use_ref=是否加入 Referer（Y/N，預設為N）: 
if "%use_ref%"=="" set use_ref=N

set "ref="
if /i "%use_ref%"=="Y" (
    set "ref=--referer=https://www.bilibili.com/"
)

:: 產生唯一暫存文件?名稱（title + uuid）
for /f %%a in ('powershell -command "[guid]::NewGuid().ToString()"') do set "folder_uuid=%%a"
set "temp_dir=%title%_%folder_uuid%"
if not exist "%temp_dir%" mkdir "%temp_dir%"

:: 產生暫存檔 UUID
for /f %%a in ('powershell -command "[guid]::NewGuid().ToString()"') do set v_uuid=%%a
for /f %%a in ('powershell -command "[guid]::NewGuid().ToString()"') do set a_uuid=%%a

:: 建立輸出文件?
set "output_dir=Download"
if not exist "%output_dir%" mkdir "%output_dir%"
set "output_path=%output_dir%\%title%.mp4"

:: 下載視頻
echo 正在下載視頻...
aria2c -x 16 -s 10 -c -o "%temp_dir%\%v_uuid%.m4s" %ref% "%video_url%"
if errorlevel 1 (
    echo 視頻下載失敗！
    pause
    exit /b
)

:: 下載音頻
echo 正在下載音頻...
aria2c -x 16 -s 10 -c -o "%temp_dir%\%a_uuid%.m4s" %ref% "%audio_url%"
if errorlevel 1 (
    echo 音頻下載失敗！
    pause
    exit /b
)

:: 合併
echo 正在合併視頻與音頻...
ffmpeg -i "%temp_dir%\%v_uuid%.m4s" -i "%temp_dir%\%a_uuid%.m4s" -c copy "%output_path%" -y
if errorlevel 1 (
    echo 合併失敗！
    pause
    exit /b
)

:: 刪除暫存文件與文件?（安全）
if defined v_uuid if exist "%temp_dir%\%v_uuid%.m4s" del /f /q "%temp_dir%\%v_uuid%.m4s"
if defined a_uuid if exist "%temp_dir%\%a_uuid%.m4s" del /f /q "%temp_dir%\%a_uuid%.m4s"
echo %temp_dir% | findstr /i "%title%_" >nul && (
    if exist "%temp_dir%\" rd /s /q "%temp_dir%"
)

echo 完成！輸出文件為：%output_path%

:: 播放提示音
powershell -c "(New-Object Media.SoundPlayer 'C:\Windows\Media\Windows Notify Calendar.wav').PlaySync()"

:: 顯示通知
powershell -Command "& { [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null; $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02); $textNodes = $template.GetElementsByTagName('text'); $textNodes.Item(0).AppendChild($template.CreateTextNode('下載完成')) > $null; $textNodes.Item(1).AppendChild($template.CreateTextNode('已成功產生 %title%.mp4')) > $null; $toast = [Windows.UI.Notifications.ToastNotification]::new($template); $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('小電視下載工具'); $notifier.Show($toast) }"

pause
