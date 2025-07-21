import subprocess
import json

def probe_audio_bitrate(file_path):
    cmd = [
        "ffprobe", "-v", "error",
        "-select_streams", "a",   # 只选音频流
        "-show_entries", "stream=bit_rate",
        "-print_format", "json",
        file_path
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print("ffprobe failed:", result.stderr)
        return

    data = json.loads(result.stdout)
    streams = data.get("streams", [])
    if not streams:
        print("未找到音频流")
        return

    for i, stream in enumerate(streams):
        bit_rate = stream.get("bit_rate", None)
        print(f"音频流 #{i+1} 码率 bit_rate: {bit_rate}")

if __name__ == "__main__":
    file_path = r"G:\N_m3u8DL-CLI 3 in 1\ready\30734616537_w1-1-30260.m4s"
    probe_audio_bitrate(file_path)
