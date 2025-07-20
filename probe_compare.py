import subprocess
import json
import sys
import os
import re  # <== 加上这行
import datetime
from colorama import init, Fore, Style

init()  # 初始化 colorama，Windows cmd 支持 ANSI 颜色

def probe_file(path):
    cmd = [
        "ffprobe", "-v", "error",
        "-print_format", "json",
        "-show_format",
        "-show_streams",
        path
    ]

    result = subprocess.run(cmd, capture_output=True, timeout=10, shell=False)

    if result.returncode != 0:
        print(f"ffprobe failed for {path}")
        print(result.stderr.decode('utf-8', errors='ignore'))
        sys.exit(1)

    try:
        output = result.stdout.decode('utf-8', errors='ignore')
        return json.loads(output)
    except Exception as e:
        print(f"解析 ffprobe 输出失败: {e}")
        print("ffprobe raw output:")
        print(result.stdout)
        sys.exit(1)

def get_video_stream(streams):
    for s in streams:
        if s.get("codec_type") == "video":
            return s
    return None

def get_audio_stream(streams):
    for s in streams:
        if s.get("codec_type") == "audio":
            return s
    return None

def format_size(size_bytes):
    try:
        mb = float(size_bytes) / 1024 / 1024
        return f"{mb:.2f} MB"
    except:
        return "N/A"

def format_duration(seconds):
    if seconds is None:
        return "N/A"
    try:
        s = float(seconds)
    except:
        return "N/A"
    h = int(s // 3600)
    m = int((s % 3600) // 60)
    sec = s % 60
    return f"{h:02d}:{m:02d}:{sec:05.2f}"

def format_bitrate(b, size_bytes=None, duration_sec=None):
    try:
        if b is None or float(b) < 1000:
            # 当码率为空或者小于1000时，尝试估算
            if size_bytes and duration_sec and float(duration_sec) > 0:
                kbps = (float(size_bytes) * 8) / float(duration_sec) / 1000
                return f"~{kbps:.0f} kbps"
            else:
                return "N/A"
        else:
            kbps = float(b) / 1000
            return f"{int(kbps)} kbps"
    except:
        return "N/A"

def format_fps(fps_str):
    if fps_str is None:
        return "N/A"
    if "/" in fps_str:
        try:
            num, den = fps_str.split("/")
            fps = float(num) / float(den)
            return f"{fps:.3f} fps"
        except:
            return fps_str
    else:
        try:
            fps = float(fps_str)
            return f"{fps:.3f} fps"
        except:
            return fps_str

def normalize_codec(codec):
    if codec is None:
        return "N/A"
    codec = codec.lower()
    mapping = {
        "h264": "AVC (H.264)",
        "hevc": "HEVC (H.265)",
        "mpeg4": "MPEG-4",
        "vp9": "VP9",
        "av1": "AV1",
        "wmv3": "WMV3",
        "vc1": "VC-1",
        "aac": "AAC",
        "mp3": "MP3",
    }
    return mapping.get(codec, codec)

def format_pix_fmt(pix_fmt):
    if not pix_fmt:
        return "N/A"
    match = re.search(r'(\d+)le$', pix_fmt)
    if match:
        bit = match.group(1)
    else:
        bit = "8"
    return f"{pix_fmt} {bit}bit"

def print_line(label, left, right, label_width=6, col_width=18):
    left_pad = left.ljust(col_width)
    right_pad = right.ljust(col_width)
    print(f"{label.ljust(label_width)} | "
          f"{Fore.LIGHTGREEN_EX}{left_pad}{Style.RESET_ALL} | "
          f"{Fore.CYAN}{right_pad}{Style.RESET_ALL}")

def get_main_format(fmt_name, brand, ext):
    ext = ext.lower()
    fmt_name = (fmt_name or "").lower()
    brand = (brand or "").lower()

    mainfmt = "unknown"
    # 1. 根据扩展名先判断
    if ext:
        mainfmt = ext

    # 2. 用 format_name 判断，如果和扩展名冲突，保持扩展名判断
    if fmt_name not in ("mov,mp4,m4a,3gp,3g2,mj2", "matroska,webm"):
        # 非这两个完整字符串时用 fmt_name 直接覆盖 mainfmt
        mainfmt = fmt_name

    # 3. 用 brand 判断 mp4/mov 覆盖，可信度最高
    if "qt" in brand:
        mainfmt = "mov"
    elif "mp4" in brand:
        mainfmt = "mp4"

    return mainfmt

def get_script_mod_date():
    try:
        # 获取当前脚本完整路径
        script_path = os.path.abspath(__file__)
        ts = os.path.getmtime(script_path)
        dt = datetime.datetime.fromtimestamp(ts)
        return dt.strftime("%Y-%m-%d")
    except Exception:
        return "N/A"

def main(file1, file2):
    script_update = get_script_mod_date()
    
    info1 = probe_file(file1)
    info2 = probe_file(file2)

    fmt1 = info1.get("format", {})
    fmt2 = info2.get("format", {})

    streams1 = info1.get("streams", [])
    streams2 = info2.get("streams", [])

    v1 = get_video_stream(streams1)
    v2 = get_video_stream(streams2)

    a1 = get_audio_stream(streams1)
    a2 = get_audio_stream(streams2)

    ext1 = os.path.splitext(file1)[1]
    ext2 = os.path.splitext(file2)[1]

    mainfmt1 = get_main_format(fmt1.get("format_name"), fmt1.get("brand"), ext1)
    mainfmt2 = get_main_format(fmt2.get("format_name"), fmt2.get("brand"), ext2)

    print("==========================================================")
    print("视频比对工具 by 163")
    print("==========================================================")
    print(f"文件1: {os.path.basename(file1)}")
    print(f"　路徑: {file1}")
    print(f"文件2: {os.path.basename(file2)}")
    print(f"　路徑: {file2}")
    print()
    print("===============*====================*====================")
    print(Fore.YELLOW + "文件" + Style.RESET_ALL)
    print_line("　大小　　　　", 
           format_size(fmt1.get('size', 0)), 
           format_size(fmt2.get('size', 0)))
    print_line("　封装格式　　", mainfmt1, mainfmt2)
    print_line("　时长　　　　", format_duration(fmt1.get("duration")), format_duration(fmt2.get("duration")))
    print(Fore.YELLOW + "视频流 #1" + Style.RESET_ALL)
    video_codec1 = v1.get("codec_name") if v1 else None
    video_codec2 = v2.get("codec_name") if v2 else None
    print_line("　视频编码　　", normalize_codec(video_codec1), normalize_codec(video_codec2))
    if not video_codec1 or video_codec1 == "N/A":
        video_bitrate1 = "N/A"
    else:
        video_bitrate1 = format_bitrate(v1.get("bit_rate"), fmt1.get("size"), fmt1.get("duration"))
    if not video_codec2 or video_codec2 == "N/A":
        video_bitrate2 = "N/A"
    else:
        video_bitrate2 = format_bitrate(v2.get("bit_rate"), fmt2.get("size"), fmt2.get("duration"))
    print_line("　视频码率　　", video_bitrate1, video_bitrate2)
    print_line("　帧率　　　　", format_fps(v1.get("avg_frame_rate") if v1 else None), format_fps(v2.get("avg_frame_rate") if v2 else None))
    res1 = f"{v1.get('width','N/A')}x{v1.get('height','N/A')}" if v1 else "N/A"
    res2 = f"{v2.get('width','N/A')}x{v2.get('height','N/A')}" if v2 else "N/A"
    print_line("　分辨率　　　", res1, res2)
    print_line("　色彩深度　　", format_pix_fmt(v1.get("pix_fmt") if v1 else None),
                         format_pix_fmt(v2.get("pix_fmt") if v2 else None))
    print(Fore.YELLOW + "音频流 #1" + Style.RESET_ALL)
    audio_codec1 = a1.get("codec_name") if a1 else None
    audio_codec2 = a2.get("codec_name") if a2 else None
    print_line("　音频编码　　", normalize_codec(audio_codec1), normalize_codec(audio_codec2))
    if not audio_codec1 or audio_codec1 == "N/A":
        audio_bitrate1 = "N/A"
    else:
        audio_bitrate1 = format_bitrate(a1.get("bit_rate"), fmt1.get("size"), fmt1.get("duration"))
    if not audio_codec2 or audio_codec2 == "N/A":
        audio_bitrate2 = "N/A"
    else:
        audio_bitrate2 = format_bitrate(a2.get("bit_rate"), fmt2.get("size"), fmt2.get("duration"))
    print_line("　音频码率　　", audio_bitrate1, audio_bitrate2)
    print_line("　声道　　　　", str(a1.get("channels") if a1 else "N/A"), str(a2.get("channels") if a2 else "N/A"))
    print_line("　采样率　　　",
            (a1.get("sample_rate") + " Hz") if a1 and a1.get("sample_rate") else "N/A",
            (a2.get("sample_rate") + " Hz") if a2 and a2.get("sample_rate") else "N/A")
    print("===============*====================*====================")
    print()

    print(f"更新日期: {script_update}")  # <== 这里打印脚本最后修改时间
    print("=========================================================")
    print()

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("用法: python probe_compare.py <file1> <file2>")
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
