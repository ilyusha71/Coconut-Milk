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
        self.root.title("GIF 生成器 by 163")
        self.video_path = ""         # 视频文件路径
        self.cap = None              # OpenCV视频捕获对象
        self.playing = False         # 播放状态
        self.frame_rate = 30         # 帧率，默认30，实际从视频中读
        self.current_frame = 0       # 当前帧号
        self.total_frames = 0        # 视频总帧数
        self.duration = 0            # 视频时长，秒
        self.crop_rect = None        # 裁剪区域 (x, y, w, h)
        self.start_x = self.start_y = None   # 鼠标拖拽起点
        self.rect_id = None          # 画布上的裁剪框ID
        self.toggle_btn = None       # 播放/暂停按钮引用

        self.play_thread = None      # 播放线程
        self.stop_event = threading.Event()  # 停止播放线程事件

        self.start_frame = None      # 起点帧
        self.end_frame = None        # 终点帧

        self.setup_ui()

    def setup_ui(self):
        self.canvas = tk.Canvas(self.root, width=720, height=405, bg="black")
        self.canvas.pack()

        btn_frame = tk.Frame(self.root)
        btn_frame.pack()

        tk.Button(btn_frame, text="选择视频", command=self.open_file).pack(side="left", padx=10)
        self.toggle_btn = tk.Button(btn_frame, text="▶ 播放", command=self.toggle_play_pause)
        self.toggle_btn.pack(side="left")
        tk.Button(btn_frame, text="◀ 上一帧", command=self.prev_frame).pack(side="left", padx=5)
        tk.Button(btn_frame, text="下一帧 ▶", command=self.next_frame).pack(side="left", padx=5)

        # 改成先创建两个容器 Frame，里面放控件，方便动态切换
        tk.Button(btn_frame, text="设定起点", command=self.set_start_frame).pack(side="left", padx=5)
        self.start_container = tk.Frame(btn_frame)
        self.start_container.pack(side="left", padx=5)

        tk.Button(btn_frame, text="设定终点", command=self.set_end_frame).pack(side="left", padx=5)
        self.end_container = tk.Frame(btn_frame)
        self.end_container.pack(side="left", padx=5)

        tk.Button(btn_frame, text="导出GIF", command=self.export_gif).pack(side="left", padx=10)

        # 先默认显示标签（未设定）
        self.start_label = tk.Label(self.start_container, text="起点: 未设定")
        self.start_label.pack()

        self.end_label = tk.Label(self.end_container, text="终点: 未设定")
        self.end_label.pack()

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

        # 新增导出宽度选择
        tk.Label(status_frame, text="导出宽度:").pack(side="left", padx=(20, 5))
        self.width_var = tk.StringVar()
        self.width_var.set("240")  # 默认值
        width_options = ["240", "320", "480", "720", "原始大小"]
        self.width_menu = tk.OptionMenu(status_frame, self.width_var, *width_options)
        self.width_menu.pack(side="left")


        self.canvas.bind("<ButtonPress-1>", self.on_mouse_down)
        self.canvas.bind("<B1-Motion>", self.on_mouse_drag)
        self.canvas.bind("<ButtonRelease-1>", self.on_mouse_up)

        self.crop_info_label = tk.Label(self.root, text="裁剪区域：未设定", fg="green", font=("Arial", 10))
        self.crop_info_label.pack(pady=3)

    def toggle_play_pause(self):
        if self.playing:
            self.pause_video()
            self.toggle_btn.config(text="▶ 播放")
        else:
            # ✅ 如果当前帧在结尾，回到起点
            if self.current_frame >= self.total_frames:
                self.current_frame = 0
                if self.cap: # 跳帧情况下才使用Set
                    self.cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
            self.play_video()
            self.toggle_btn.config(text="⏸ 暂停")

    def refresh_start_end_display(self):
        # 清空容器内控件
        for widget in self.start_container.winfo_children():
            widget.destroy()
        for widget in self.end_container.winfo_children():
            widget.destroy()

        # 起点显示逻辑
        if self.start_frame is not None and 0 <= self.start_frame < self.total_frames:
            btn = tk.Button(
                self.start_container,
                text=f"{self.start_frame}",
                command=lambda: self.jump_to_frame(self.start_frame),
                bg="#ffcc00",  # ✅ 设置背景为高亮黄色
                fg="black",
                font=("Arial", 10, "bold")
            )
            btn.pack()
        else:
            lbl = tk.Label(self.start_container, text="未设定")
            lbl.pack()

        # 终点显示逻辑
        if self.end_frame is not None and 0 <= self.end_frame < self.total_frames:
            btn = tk.Button(
                self.end_container,
                text=f"{self.end_frame}",
                command=lambda: self.jump_to_frame(self.end_frame),
                bg="#00ccff",  # ✅ 设置背景为高亮蓝色
                fg="black",
                font=("Arial", 10, "bold")
            )
            btn.pack()
        else:
            lbl = tk.Label(self.end_container, text="未设定")
            lbl.pack()
            
    def set_start_frame(self):
        if self.cap:
            self.start_frame = self.current_frame
            self.refresh_start_end_display()
            print(f"✅ 设定起点帧: {self.start_frame}")
        else:
            print("⚠️ 请先载入视频")

    def set_end_frame(self):
        if self.cap:
            self.end_frame = self.current_frame
            self.refresh_start_end_display()
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
            export_width = self.width_var.get()
            if export_width != "原始大小":
                scale_str = f"scale={export_width}:-1:flags=lanczos"
            else:
                scale_str = "scale=iw:ih:flags=lanczos"

            palette_filter = f"fps=15"
            if crop_filter:
                palette_filter += f",{crop_filter}"
            palette_filter += f",{scale_str},palettegen"


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
            complex_filter += f",{scale_str}[x];[x][1:v]paletteuse"


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

        # 视频原始尺寸
        vw, vh = self.video_width, self.video_height
        # canvas 尺寸
        cw, ch = 720, 405

        # 计算缩放比例，保持比例缩放后的实际显示尺寸
        scale = min(cw / vw, ch / vh)
        display_w = int(vw * scale)
        display_h = int(vh * scale)

        # 居中偏移
        x_offset = (cw - display_w) // 2
        y_offset = (ch - display_h) // 2

        # 裁剪区域相对于显示图像的坐标（去掉居中偏移）
        rel_x = x - x_offset
        rel_y = y - y_offset

        # 显示区域内的裁剪位置必须在 [0, display_w/h]
        if rel_x < 0 or rel_y < 0 or rel_x + w > display_w or rel_y + h > display_h:
            print("❌ 裁剪区域超出视频显示范围")
            return None

        # 映射回原始视频坐标
        vx = int(rel_x / scale)
        vy = int(rel_y / scale)
        vw = int(w / scale)
        vh = int(h / scale)

        # 修正溢出
        if vx + vw > self.video_width:
            vw = self.video_width - vx
        if vy + vh > self.video_height:
            vh = self.video_height - vy
        if vw <= 0 or vh <= 0:
            return None

        return f"crop={vw}:{vh}:{vx}:{vy}"


    def on_enter_jump_time(self, event=None):
        #self.pause_video()
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
        """當按下 Enter 鍵跳轉至指定幀時觸發"""
        frame_text = self.frame_entry.get().strip()
        if not frame_text.isdigit():
            print("❌ 請輸入有效的幀數字")
            return
        frame_num = int(frame_text)
        self.jump_to_frame(frame_num)

    def open_file(self):
        self.pause_video()  # ✅ 新增：先暂停当前播放
        path = filedialog.askopenfilename(filetypes=[("Video files", "*.mp4 *.mkv *.mov *.avi")])
        if not path:
            return
        print(f"✅ 选中视频路径: {path}")  # 新增，方便调试
        self.load_video(path)

    def load_video(self, path):
        self.pause_video()
        if self.play_thread and self.play_thread.is_alive():
            self.playing = False  # 停止播放状态
            self.stop_event.set()
            self.play_thread.join(timeout=1)  # 加个超时，防止死等
            if self.play_thread.is_alive():
                print("⚠️ 播放线程未正常退出，可能存在风险")
        self.stop_event.clear()
        self.play_thread = None  # 清空线程对象

        # 释放旧资源
        if self.cap:
            self.cap.release()
            self.cap = None

        # 清理残留状态
        self.playing = False
        self.crop_rect = None
        self.start_frame = None
        self.end_frame = None
        if self.rect_id:
            self.canvas.delete(self.rect_id)
            self.rect_id = None

        # 然后继续加载新视频
        self.video_path = path
        self.output_dir = os.path.dirname(self.video_path)
        self.cap = cv2.VideoCapture(self.video_path)
        if not self.cap.isOpened():
            print(f"❌ 无法打开视频文件：{self.video_path}")
            messagebox.showerror("错误", "无法打开该视频文件，请选择其他文件。")
            self.cap = None
            return
        self.video_width = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        self.video_height = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        self.frame_rate = self.cap.get(cv2.CAP_PROP_FPS)
        if self.frame_rate == 0 or self.frame_rate is None:
            self.frame_rate = 30  # 默认值，防止除0
        self.total_frames = int(self.cap.get(cv2.CAP_PROP_FRAME_COUNT))
        self.duration = self.total_frames / self.frame_rate if self.frame_rate else 0
        self.current_frame = 0
        self.cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
        
        self.show_frame(self.current_frame)
        self.update_time_label()
        self.refresh_start_end_display()  # 新增这里刷新显示
        
        print(f"✅ 载入视频：{os.path.basename(path)}，总帧数：{self.total_frames}，FPS：{self.frame_rate:.2f}")
        
        self.play_video()

    # 视频显示
    def show_frame(self, frame_num):
        if not self.cap:
            return
        self.cap.set(cv2.CAP_PROP_POS_FRAMES, frame_num)
        ret, frame = self.cap.read()
        if ret:
            self.show_image(frame)

    def show_image(self, frame):
        img = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        vh, vw = img.shape[:2]
        canvas_w, canvas_h = 720, 405

        scale = min(canvas_w / vw, canvas_h / vh)
        new_w, new_h = int(vw * scale), int(vh * scale)

        resized = cv2.resize(img, (new_w, new_h), interpolation=cv2.INTER_AREA)
        pil_img = Image.fromarray(resized)
        imgtk = ImageTk.PhotoImage(image=pil_img)

        x_offset = canvas_w // 2
        y_offset = canvas_h // 2

        # 不用每次清空画布，改成更新已有图像，非常重要能大幅度提升播放流畅度
        if hasattr(self, '_image_id'):
            self.canvas.itemconfig(self._image_id, image=imgtk)
        else:
            self._image_id = self.canvas.create_image(x_offset, y_offset, anchor=tk.CENTER, image=imgtk)

        self.canvas.image = imgtk  # 保留引用



    def update_time_label(self):
        cur_sec = self.current_frame / self.frame_rate if self.frame_rate else 0
        dur_sec = self.duration
        self.time_label.config(text=f"时间：{self.format_time(cur_sec)} / {self.format_time(dur_sec)}")
        self.frame_label.config(text=f"帧数: {self.current_frame} / {self.total_frames}")

    def play_loop(self):
        next_time = time.time()
        while self.playing and self.cap.isOpened():
            if self.stop_event.is_set():
                break
            #start_time = time.time()
            ret, frame = self.cap.read()
            if not ret:
                self.playing = False
                break

            self.current_frame += 1
            self.show_image(frame)
            self.update_time_label()

            next_time += 1 / self.frame_rate
            sleep_time = max(0, next_time - time.time())

            # 用分段睡眠，快速响应stop_event
            slept = 0
            while slept < sleep_time:
                if self.stop_event.is_set():
                    break
                time.sleep(min(0.01, sleep_time - slept))
                slept += 0.01

            if self.current_frame >= self.total_frames:
                self.playing = False
                if self.toggle_btn:
                    self.toggle_btn.config(text="▶ 播放")
                break

    # 播放控制
    def play_video(self):
        if not self.cap:
            print("请先选择视频")
            return
        if self.playing:
            return
        # 不调用cap.set
        # if self.current_frame >= self.total_frames:
        #     self.cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
        #     self.current_frame = 0
        # else:
        #     self.cap.set(cv2.CAP_PROP_POS_FRAMES, self.current_frame)
        self.playing = True
        if self.toggle_btn:
            self.toggle_btn.config(text="⏸ 暂停")

        self.stop_event.clear()
        self.play_thread = threading.Thread(target=self.play_loop, daemon=True)
        self.play_thread.start()

    def pause_video(self):
        self.playing = False
        self.stop_event.set()
        # 不阻塞等待线程退出，直接返回
        # if self.play_thread and self.play_thread.is_alive():
        #     self.play_thread.join(timeout=1)
        
        if self.toggle_btn:
            self.toggle_btn.config(text="▶ 播放")
        
        self.stop_event.clear()

    # 帧控制
    def prev_frame(self):
        if self.current_frame > 0:
            self.current_frame -= 1
            self.show_frame(self.current_frame)

    def next_frame(self):
        if self.current_frame + 1 < self.total_frames:
            self.current_frame += 1
            self.show_frame(self.current_frame)

    def jump_to_frame(self, frame_num):
        try:
            frame_index = int(frame_num)
        except ValueError:
            print("❌ 幀數轉換失敗")
            return

        if frame_index < 0 or frame_index >= self.total_frames:
            print(f"❌ 幀號超出範圍（0 ~ {self.total_frames - 1}）")
            return

        self.current_frame = frame_index
        self.show_frame(frame_index)
        self.update_time_label()


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
#1749 暂停可加载新，即将开始root
#1910 开启档案时暂停，可加载，但是新加载影片无法跳帧
#1930 优化播放暂停按钮 不使用cap.set