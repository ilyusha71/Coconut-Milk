import subprocess
import json
import sys
import os

def get_format_info(path):
    try:
        result = subprocess.run([
            "ffprobe", "-v", "quiet",
            "-print_format", "json",
            "-show_format", "-show_streams",
            path
        ], capture_output=True, text=True, encoding="utf-8")  # 加了 encoding
        return json.loads(result.stdout)
    except Exception as e:
        print(f"ffprobe 解析失敗: {e}")
        return {}

def detect_container(info):
    format_name = info.get("format", {}).get("format_name", "")
    tags = info.get("format", {}).get("tags", {})

    # 優先根據 format_name 判斷
    if "matroska" in format_name or "webm" in format_name:
        return "MKV"
    if "mp4" in format_name or "mov" in format_name:
        return "MP4"

    # 補充判斷：tag 中可能有 major_brand
    brand = tags.get("major_brand") or tags.get("compatible_brands", "")
    if brand:
        if "mp42" in brand or "isom" in brand:
            return "MP4"

    return "其他格式"

# 手動指定測試檔案
#file_path = r"G:\g.国漫\r若鸿文化\完结\d斗战天下\删\斗战T下.S01EP20.2024.2160p.WEB-DL.HEVC.EDR.DDP2.0.mp4"
file_path = r"G:\g.国漫\r若鸿文化\w1.5.无上神帝\1080p SDR(164)\无上神帝第502话 高清SDR(1080P) 322164.mp4"

if not os.path.exists(file_path):
    print("❌ 找不到文件！")
    sys.exit(1)

info = get_format_info(file_path)

print("==== 文件格式資訊 ====")
if info:
    print(json.dumps(info["format"], indent=2, ensure_ascii=False))
else:
    print("⚠ 無法取得 ffprobe 資訊")

print("\n==== 判斷封裝格式 ====")
fmt = detect_container(info)
if fmt == "MKV":
    print("[✔] 該文件為 MKV 封裝")
elif fmt == "MP4":
    print("[?] 該文件應為 MP4 或其他非 MKV 封裝")
else:
    print("[!] 無法判斷封裝格式")
