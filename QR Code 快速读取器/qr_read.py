import sys
import cv2
from pyzbar.pyzbar import decode
import pyperclip
from PIL import Image
import os

def read_qr_code(image_path):
    try:
        # 嘗試使用 OpenCV 讀取圖片
        image = cv2.imread(image_path)
        if image is None:
            print("❌ 無法讀取圖片。")
            return

        # 解碼
        decoded_objects = decode(image)
        if not decoded_objects:
            print("❌ 沒有識別到任何二維碼。")
            return

        for obj in decoded_objects:
            data = obj.data.decode("utf-8")
            pyperclip.copy(data)
            print("✅ 成功讀取並複製到剪貼簿：")
            print(data)
            return
    except Exception as e:
        print(f"❌ 發生錯誤：{e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("請將圖片拖到此 bat 檔案上。")
    else:
        image_path = sys.argv[1]
        if os.path.isfile(image_path):
            read_qr_code(image_path)
        else:
            print("❌ 無效的檔案路徑。")
