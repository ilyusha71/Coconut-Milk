from tkinter import messagebox
import numpy as np
import tkinter as tk
from tkinter import filedialog
import cv2
from PIL import Image, ImageTk
import threading
import time
import os
import sys
import subprocess  # 新增：调用ffmpeg
import tempfile


class VideoPlayer:
    def __init__(self, root):
        self.root = root
        self.root.title("选择视频片段制作GIF")
        self.video_path = ""
        self.cap = None
        self.playing = False
        self.frame_rate = 30
        self.current_frame = 0
        self.total_frames = 0
        self.duration = 0
        self.crop_rect = None  # 裁剪区域 (x, y, w, h)
        self.start_x = self.start_y = None
        self.rect_id = None  # Canvas上画的矩形ID

        # 新增：起点和终点帧
        self.start_frame = None
        self.end_frame = None

        self.setup_ui()

    def setup_ui(self):
        self.canvas = tk.Canvas(self.root, width=720, height=405, bg="black")
        self.canvas.pack()

        btn_frame = tk.Frame(self.root)
        btn_frame.pack()

        tk.Button(btn_frame, text="选择视频", command=self.open_file).pack(side="left", padx=10)
        tk.Button(btn_frame, text="▶ 播放", command=self.play_video).pack(side="left")
        tk.Button(btn_frame, text="⏸ 暂停", command=self.pause_video).pack(side="left")
        tk.Button(btn_frame, text="◀ 上一帧", command=self.prev_frame).pack(side="left", padx=5)
        tk.Button(btn_frame, text="下一帧 ▶", command=self.next_frame).pack(side="left", padx=5)
        tk.Button(btn_frame, text="设定起点", command=self.set_start_frame).pack(side="left", padx=5)
        tk.Button(btn_frame, text="设定终点", command=self.set_end_frame).pack(side="left", padx=5)
        tk.Button(btn_frame, text="导出GIF", command=self.export_gif).pack(side="left", padx=10)

        self.start_label = tk.Label(btn_frame, text="起点: 未设定")
        self.start_label.pack(side="left", padx=5)
        self.end_label = tk.Label(btn_frame, text="终点: 未设定")
        self.end_label.pack(side="left", padx=5)

        status_frame = tk.Frame(self.root)
        status_frame.pack(pady=5)

        self.time_label = tk.Label(status_frame, text="时间：00:00 / 00:00")
        self.time_label.pack(side="left", padx=(0, 10))

        self.time_entry = tk.Entry(status_frame, width=10)
        self.time_entry.insert(0, "时间")
        self.time_entry.bind("<FocusIn>", lambda e: self.time_entry.delete(0, tk.END))
        self.time_entry.pack(side="left")
        self.time_entry.bind("<Return>", self.on_enter_jump_time)

        tk.Button(status_frame, text="时间跳转", command=self.on_enter_jump_time).pack(side="left", padx=(5, 15))

        self.frame_label = tk.Label(status_frame, text="帧数: 0 / 0")
        self.frame_label.pack(side="left", padx=(0, 10))

        self.frame_entry = tk.Entry(status_frame, width=10)
        self.frame_entry.insert(0, "帧数")
        self.frame_entry.bind("<FocusIn>", lambda e: self.frame_entry.delete(0, tk.END))
        self.frame_entry.pack(side="left")
        self.frame_entry.bind("<Return>", self.on_enter_jump_frame)

        tk.Button(status_frame, text="帧数跳转", command=self.on_enter_jump_frame).pack(side="left", padx=(5, 0))

        self.canvas.bind("<ButtonPress-1>", self.on_mouse_down)
        self.canvas.bind("<B1-Motion>", self.on_mouse_drag)
        self.canvas.bind("<ButtonRelease-1>", self.on_mouse_up)

        self.crop_info_label = tk.Label(self.root, text="裁剪区域：未设定", fg="green", font=("Arial", 10))
        self.crop_info_label.pack(pady=3)

    def set_start_frame(self):
        if self.cap:
            self.start_frame = self.current_frame
            self.start_label.config(text=f"起点: {self.start_frame}")
            print(f"✅ 设定起点帧: {self.start_frame}")
        else:
            print("⚠️ 请先载入视频")

    def set_end_frame(self):
        if self.cap:
            self.end_frame = self.current_frame
            self.end_label.config(text=f"终点: {self.end_frame}")
            print(f"✅ 设定终点帧: {self.end_frame}")
        else:
            print("⚠️ 请先载入视频")

    def export_gif(self):
        if not self.cap:
            print("⚠️ 请先载入视频")
            return
        if self.start_frame is None or self.end_frame is None:
            print("⚠️ 请先设定起点和终点")
            return
        if self.start_frame >= self.end_frame:
            print("⚠️ 起点必须小于终点")
            return

        output_path = filedialog.asksaveasfilename(
            defaultextension=".gif",
            filetypes=[("GIF files", "*.gif")],
            title="保存GIF文件"
        )
        if not output_path:
            return

        start_time = self.start_frame / self.frame_rate
        duration = (self.end_frame - self.start_frame + 1) / self.frame_rate
        palette_path = os.path.join(tempfile.gettempdir(), "palette.png").replace("\\", "/")

        try:
            crop_filter = self.get_crop_filter()
            palette_filter = "fps=15"
            if crop_filter:
                palette_filter += f",{crop_filter}"
            palette_filter += ",scale=720:-1:flags=lanczos,palettegen"

            cmd1 = [
                "ffmpeg", "-ss", f"{start_time:.3f}", "-t", f"{duration:.3f}",
                "-i", self.video_path,
                "-vf", palette_filter,
                "-y", palette_path
            ]

            print("生成调色板...")
            subprocess.run(cmd1, check=True)

            complex_filter = "fps=15"
            if crop_filter:
                complex_filter += f",{crop_filter}"
            complex_filter += ",scale=720:-1:flags=lanczos[x];[x][1:v]paletteuse"

            cmd2 = [
                "ffmpeg", "-ss", f"{start_time:.3f}", "-t", f"{duration:.3f}",
                "-i", self.video_path, "-i", palette_path,
                "-filter_complex", complex_filter,
                "-y", output_path
            ]

            print("生成GIF...")
            subprocess.run(cmd2, check=True)
            print(f"✅ GIF 导出成功: {output_path}")
            messagebox.showinfo("导出成功", f"GIF 已成功储存：\n{output_path}")

        except subprocess.CalledProcessError as e:
            print(f"❌ GIF 导出失败: {e}")
        finally:
            if os.path.exists(palette_path):
                os.remove(palette_path)

    def get_crop_filter(self):
        if not self.crop_rect:
            return None
        x, y, w, h = self.crop_rect
        scale_x = self.video_width / 720
        scale_y = self.video_height / 405
        vx = int(x * scale_x)
        vy = int(y * scale_y)
        vw = int(w * scale_x)
        vh = int(h * scale_y)
        if vx + vw > self.video_width:
            vw = self.video_width - vx
        if vy + vh > self.video_height:
            vh = self.video_height - vy
        if vw <= 0 or vh <= 0:
            return None
        return f"crop={vw}:{vh}:{vx}:{vy}"

    def on_enter_jump_time(self, event=None):
        self.pause_video()
        val = self.time_entry.get().strip()
        try:
            if ":" in val:
                parts = val.split(":")
                if len(parts) != 2:
                    raise ValueError("时间格式错误")
                m = int(parts[0])
                s = float(parts[1])
                total_seconds = m * 60 + s
            else:
                fval = float(val)
                sval = str(int(fval))
                decimal_part = fval - int(fval)
                if len(sval) <= 2:
                    total_seconds = fval
                else:
                    minutes = int(sval[:-2])
                    seconds = int(sval[-2:]) + decimal_part
                    if seconds >= 60:
                        minutes += int(seconds // 60)
                        seconds = seconds % 60
                    total_seconds = minutes * 60 + seconds
            frame_num = int(total_seconds * self.frame_rate)
            self.jump_to_frame(frame_num)
        except Exception:
            print("⚠️ 请输入正确格式的时间，如 mm:ss 或符合规则的纯数字")

    def on_enter_jump_frame(self, event=None):
        self.pause_video()
        val = self.frame_entry.get()
        try:
            frame_num = int(val)
            self.jump_to_frame(frame_num)
        except ValueError:
            print("⚠️ 请输入有效的整数帧数")

    def open_file(self):
        path = filedialog.askopenfilename(filetypes=[("Video files", "*.mp4 *.mkv *.mov *.avi")])
        if not path:
            return
        self.load_video(path)

    def load_video(self, path):
        if self.cap:
            self.cap.release()
        self.video_path = path
        self.output_dir = os.path.dirname(self.video_path)
        self.cap = cv2.VideoCapture(self.video_path)
        self.video_width = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        self.video_height = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        self.frame_rate = self.cap.get(cv2.CAP_PROP_FPS)
        self.total_frames = int(self.cap.get(cv2.CAP_PROP_FRAME_COUNT))
        self.duration = self.total_frames / self.frame_rate if self.frame_rate else 0
        self.current_frame = 0
        self.playing = False
        self.show_frame(self.current_frame)
        self.update_time_label()
        print(f"✅ 载入视频：{os.path.basename(path)}，总帧数：{self.total_frames}，FPS：{self.frame_rate:.2f}")
        self.play_video()

    def show_frame(self, frame_num):
        if not self.cap:
            return
        self.cap.set(cv2.CAP_PROP_POS_FRAMES, frame_num)
        ret, frame = self.cap.read()
        if ret:
            self.show_image(frame)

    def show_image(self, frame):
        img = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        img = cv2.resize(img, (720, 405))
        pil_img = Image.fromarray(img)
        imgtk = ImageTk.PhotoImage(image=pil_img)
        self.canvas.create_image(0, 0, anchor=tk.NW, image=imgtk)
        self.canvas.image = imgtk

    def update_time_label(self):
        cur_sec = self.current_frame / self.frame_rate if self.frame_rate else 0
        dur_sec = self.duration
        self.time_label.config(text=f"时间：{self.format_time(cur_sec)} / {self.format_time(dur_sec)}")
        self.frame_label.config(text=f"帧数: {self.current_frame} / {self.total_frames}")

    def play_loop(self):
        while self.playing and self.cap.isOpened():
            ret, frame = self.cap.read()
            if not ret:
                self.playing = False
                break
            self.current_frame += 1
            self.show_image(frame)
            self.update_time_label()
            time.sleep(1 / self.frame_rate)
            if self.current_frame >= self.total_frames:
                self.playing = False
                break

    def play_video(self):
        if not self.cap:
            print("请先选择视频")
            return
        if self.playing:
            return
        if self.current_frame >= self.total_frames:
            self.cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
            self.current_frame = 0
        else:
            self.cap.set(cv2.CAP_PROP_POS_FRAMES, self.current_frame)
        self.playing = True
        threading.Thread(target=self.play_loop, daemon=True).start()

    def pause_video(self):
        self.playing = False

    def prev_frame(self):
        if self.current_frame > 0:
            self.current_frame -= 1
            self.show_frame(self.current_frame)

    def next_frame(self):
        if self.current_frame + 1 < self.total_frames:
            self.current_frame += 1
            self.show_frame(self.current_frame)

    def jump_to_frame(self, frame_num):
        if not self.cap:
            print("请先选择视频")
            return
        self.playing = False
        frame_num = int(max(0, min(frame_num, self.total_frames - 1)))
        self.current_frame = frame_num
        self.cap.set(cv2.CAP_PROP_POS_FRAMES, frame_num)
        ret, frame = self.cap.read()
        if ret:
            self.show_image(frame)
            self.update_time_label()
        else:
            print("无法跳转到该帧")

    def on_mouse_down(self, event):
        self.start_x = event.x
        self.start_y = event.y
        if self.rect_id:
            self.canvas.delete(self.rect_id)
        self.rect_id = self.canvas.create_rectangle(self.start_x, self.start_y, self.start_x, self.start_y, outline="red", width=2)

    def on_mouse_drag(self, event):
        if self.rect_id:
            self.canvas.coords(self.rect_id, self.start_x, self.start_y, event.x, event.y)

    def on_mouse_up(self, event):
        x1, y1 = self.start_x, self.start_y
        x2, y2 = event.x, event.y
        x, y = min(x1, x2), min(y1, y2)
        w, h = abs(x2 - x1), abs(y2 - y1)
        if w > 20 and h > 20:
            self.crop_rect = (x, y, w, h)
            print(f"✅ 已设置裁剪区域：x={x}, y={y}, w={w}, h={h}")
            self.crop_info_label.config(text=f"裁剪区域：x={x}, y={y}, w={w}, h={h}")
        else:
            print("❌ 裁剪区域太小，忽略")
            if self.rect_id:
                self.canvas.delete(self.rect_id)
            self.crop_rect = None
            self.crop_info_label.config(text="裁剪区域：未设定")

    @staticmethod
    def format_time(seconds):
        m = int(seconds // 60)
        s = int(seconds % 60)
        return f"{m:02d}:{s:02d}"


if __name__ == "__main__":
    root = tk.Tk()
    player = VideoPlayer(root)

    if len(sys.argv) > 1:
        video_path = sys.argv[1]
        if os.path.exists(video_path):
            player.load_video(video_path)
        else:
            print(f"❌ 找不到文件：{video_path}")

    root.mainloop()
