@echo off
setlocal

:: ���դ��
set "file=G:\g.�Ǻ�\r�Y?���\��?\d��?�ѤU\��\��?T�U.S01EP20.2024.2160p.WEB-DL.HEVC.EDR.DDP2.0.mp4"

:: �I�s ffprobe ���o json ��X
ffprobe -v error -print_format json -show_format "%file%" > "%temp%\fmt.json"

:: ��ܮ榡��T
echo.
echo ==== ���榡��T ====
type "%temp%\fmt.json" | findstr /i /c:"format_name" /c:"format_long_name" /c:"tags"

echo.
echo ==== �P�_�ʸˮ榡 ====

:: �o�̧ڭ̥i�H�ϥ�²���޿�P�_�O�_�� mkv �S�x
type "%temp%\fmt.json" | findstr /i /c:"matroska" >nul
if %errorlevel%==0 (
    echo [!] �Ӥ���ګʸˮ榡�� MKV (Matroska)
) else (
    echo [?] �Ӥ������ MP4 �Ψ�L�D MKV �ʸ�
)

echo.
pause
