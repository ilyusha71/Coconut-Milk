@echo off
setlocal enabledelayedexpansion

echo.
echo ███ WebP 圖片轉 PNG（取第一幀）███
echo ----------------------------------

:: 檢查是否拖入文件
if "%~1"=="" (
    echo 請將 .webp 文件拖曳至本批次文件以轉換為 PNG。
    pause
    exit /b
)

:: 處理每個拖入的文件
for %%F in (%*) do (
    set "filepath=%%~fF"
    set "ext=%%~xF"
    set "name=%%~nF"
    set "folder=%%~dpF"

    if /i "!ext!"==".webp" (
        echo 處理：!name!!ext!

        set "outpath=!folder!!name!.png"

        :: 提取第一幀為 PNG（無損）
        ffmpeg -y -v error -i "!filepath!" -vframes 1 -vsync 0 "!outpath!"

        if exist "!outpath!" (
            echo → 已輸出：!outpath!
        ) else (
            echo → 轉換失敗！
        )
        echo.
    ) else (
        echo [跳過] 不是 .webp 文件：%%~nxF
    )
)

echo 轉換完成。
pause
