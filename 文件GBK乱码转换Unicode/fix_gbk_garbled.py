import os
import sys

def fix_garbled_filename(filename):
    try:
        raw_bytes = filename.encode('mbcs')
        fixed = raw_bytes.decode('gbk')
        return fixed
    except Exception:
        return filename

def fix_filepath(filepath):
    filepath = os.path.abspath(filepath)
    dirname = os.path.dirname(filepath)
    filename = os.path.basename(filepath)

    fixed_name = fix_garbled_filename(filename)
    if fixed_name != filename:
        new_path = os.path.join(dirname, fixed_name)
        if not os.path.exists(new_path):
            os.rename(filepath, new_path)
            print(f"[✓] 重命名成功: {filename} → {fixed_name}")
        else:
            print(f"[!] 目标文件已存在，跳过: {fixed_name}")
    else:
        print(f"[ ] 文件名无需修改: {filename}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("请传入文件路径参数")
        sys.exit(1)

    fix_filepath(sys.argv[1])
