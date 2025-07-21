import sys
import subprocess
import os
import datetime

def input_time(prompt, default=None):
    while True:
        value = input(prompt)
        if value.strip() == "" and default:
            return default
        if value.count(":") in (0, 2):  # 00:00:05 或 5
            return value.strip()
        print("請輸入格式如 00:01:30 或 5")

def input_duration(prompt):
    while True:
        value = input(prompt)
        try:
            float(value)
            return value
        except:
            print("請輸入合法的數值（秒數）")

def input_width(prompt, default=720):
    while True:
        value = input(prompt).strip()
        if value == "":
            return default
        if value.isdigit() and int(value) > 0:
            return int(value)
        print("請輸入正整數，例如 480 或 720")

def input_crop_params():
    print("是否裁切畫面？若不需裁切請直接按 Enter。")
    w = input("　裁切寬度（如 480）：").strip()
    h = input("　裁切高度（如 270）：").strip()
    x = input("　裁切起始 X（如 100，預設為 0）：").strip() or "0"
    y = input("　裁切起始 Y（如 50，預設為 0）：").strip() or "0"

    if all(v == "" for v in [w, h]):
        return ""  # 不裁切

    if not (w.isdigit() and h.isdigit() and x.isdigit() and y.isdigit()):
        print("❌ 裁切參數格式錯誤，將跳過裁切。")
        return ""

    return f"crop={w}:{h}:{x}:{y}"

def run_cmd(cmd):
    print("執行指令：", " ".join(cmd))
    subprocess.run(cmd, check=True)

def create_high_quality_gif(input_path, start_time, duration, width, crop_filter, output_path):
    # 濾鏡鏈
    scale = f"scale={width}:-1:flags=lanczos"
    filter_chain = f"fps=10,{scale}"
    if crop_filter:
        filter_chain = f"fps=10,{crop_filter},{scale}"

    # palette path
    palette_path = os.path.join(os.path.dirname(output_path), "palette.png")

    # step 1
    cmd_palette = [
        "ffmpeg", "-y",
        "-ss", start_time,
        "-t", duration,
        "-i", input_path,
        "-vf", f"{filter_chain},palettegen",
        palette_path
    ]
    run_cmd(cmd_palette)

    # step 2
    cmd_gif = [
        "ffmpeg", "-y",
        "-ss", start_time,
        "-t", duration,
        "-i", input_path,
        "-i", palette_path,
        "-filter_complex", f"{filter_chain}[x];[x][1:v]paletteuse",
        output_path
    ]
    run_cmd(cmd_gif)

    if os.path.exists(palette_path):
        os.remove(palette_path)

if __name__ == "__main__":
    print("="*40)
    print("      視頻 ➜ 動態GIF 轉換工具")
    print("="*40)

    if len(sys.argv) < 2:
        print("請提供視頻文件路徑")
        sys.exit(1)

    video = sys.argv[1]
    basename = os.path.splitext(os.path.basename(video))[0]
    folder = os.path.dirname(video)

    # 生成帶時間戳的檔案名
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    output_gif = os.path.join(folder, f"{basename}_{timestamp}.gif")

    print("視頻文件：", video)
    width = input_width("請輸入輸出寬度（例如 480，預設 720）：")
    crop_filter = input_crop_params()
    start_time = input_time("請輸入開始時間（例如 00:01:30）：")
    duration = input_duration("請輸入持續時間（秒）：")

    try:
        create_high_quality_gif(video, start_time, duration, width, crop_filter, output_gif)
        print("\n✅ GIF 已儲存至：", output_gif)
    except subprocess.CalledProcessError:
        print("❌ 發生錯誤，請確認 ffmpeg 是否可用並檢查輸入參數")
