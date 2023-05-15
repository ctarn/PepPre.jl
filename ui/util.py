import ctypes
import json
import os
import platform
import subprocess
import sys
from urllib import request

# OS
is_linux = platform.system() == "Linux"
is_darwin = platform.system() == "Darwin"
is_windows = platform.system() == "Windows"

try:
    if is_windows: ctypes.windll.shcore.SetProcessDpiAwareness(1)
except:
    pass

def get_arch(m=platform.machine()):
    return {"AMD64": "x86_64",}.get(m, m)

# CMD
class Console:
    widget = None

    def __init__(self, widget):
        self.widget = widget

    def write(self, s):
        self.widget.config(state="normal")
        if s.endswith("\x1b[K\n"):
            self.widget.delete("end-2l", "end")
            self.widget.insert("end", "\n")
            s = s[0:-4] + "\n"
        self.widget.insert("end", s)
        self.widget.config(state="disabled")
        self.widget.update()
        self.widget.see("end")

    def flush(self):
        pass

def get_content(*path, shared=False, zipped=False):
    path = os.path.join(*path)
    if getattr(sys, 'frozen', False):
        if zipped or is_darwin: return os.path.join(sys._MEIPASS, "content", path)
        else: return os.path.join("content", path)
    else:
        if shared: return os.path.join("tmp", "shared", path)
        else: return os.path.join("tmp", f"{get_arch()}.{platform.system()}", path)

def run_cmd(cmd, handles=None, skip=False):
    if skip: return
    print("cmd: " + str(cmd))
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, encoding="utf-8", creationflags=subprocess.CREATE_NO_WINDOW if is_windows else 0,
    )
    if handles is not None: handles.append(p)
    while p.poll() is None: print(p.stdout.readline(), end="")
    for line in p.stdout.readlines(): print(line, end="")

# Task
def save_task(path, vars):
    try:
        print("task saving to", path)
        with open(path, mode="w") as io:
            json.dump({k: v.get() for k, v in vars.items()}, io)
    except:
        print("task failed to saving to", path)

def load_task(path, vars):
    print("task loading from", path)
    try:
        with open(path) as io:
            data = json.load(io)
        for k, v in vars.items():
            if k in data: v.set(data[k])
    except:
        print("task failed to loading from", path)

# UI
sty_entry = {"sticky": "WE", "pady": 1}
sty_button = {"sticky": "WE", "padx": 4, "pady": 1}

def center_window(win):
    x = int((win.winfo_screenwidth() - win.winfo_width()) / 2)
    y = int((win.winfo_screenheight() - win.winfo_height()) / 2)
    win.geometry(f"+{x}+{y}")

def show_headline(var, url):
    if not getattr(sys, 'frozen', False): return
    try:
        text = request.urlopen(f"{url}/headline").read().decode("utf-8")
        if text.startswith("NEWS:"):
            var.set(text)
    except:
        pass
