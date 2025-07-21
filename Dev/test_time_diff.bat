@echo off
setlocal

set "start=23:15:52.123"
set "end=23:15:53.456"

echo 開始計算時間差: %start% → %end%

for /f "delims=" %%i in ('powershell -NoProfile -Command "try { $start=[datetime]::ParseExact('%start%', 'HH:mm:ss.fff', $null); $end=[datetime]::ParseExact('%end%', 'HH:mm:ss.fff', $null); if ($end -lt $start) { $end = $end.AddDays(1) }; [math]::Round(($end - $start).TotalMilliseconds) } catch { -1 }"') do set diff=%%i

echo 總毫秒差為：%diff%
pause
