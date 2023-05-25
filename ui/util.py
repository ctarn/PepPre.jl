import ctypes
import json
import os
import platform
import subprocess
import sys
import tkinter as tk
from tkinter import ttk, filedialog
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
sty_label = {"sticky": "W", "padx": 4, "pady": 4}
sty_entry = {"sticky": "EW", "padx": 0, "pady": 1}
sty_button = {"sticky": "EW", "padx": 4, "pady": 1}
sty_unit = {"sticky": "EW", "padx": 0, "pady": 1}

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

def askfile(var, **kwargs):
    def s():
        path = filedialog.askopenfilename(**kwargs)
        if len(path) > 0: var.set(path)
    return s

def askdir(var, **kwargs):
    def s():
        path = filedialog.askdirectory(**kwargs)
        if len(path) > 0: var.set(path)
    return s

def init_form(f):
    ttk.Label(f, width=20 if is_windows else 16).grid(column=0, row=0)
    ttk.Label(f, width=80 if is_windows else 60).grid(column=1, row=0)
    ttk.Label(f, width=12 if is_windows else 10).grid(column=2, row=0)
    return f

def add_entry(form, row, label, entry, ext="", func=None):
    if isinstance(label, str):
        label = ttk.Label(form, text=label)
    label.grid(column=0, row=row, **sty_label)
    if isinstance(entry, tk.Variable):
        entry = ttk.Entry(form, textvariable=entry)
    entry.grid(column=1, row=row, **sty_entry)
    if isinstance(ext, str):
        if func is None:
            ext = ttk.Label(form, text=ext)
            ext.grid(column=2, row=row, **sty_unit)
        else:
            ext = ttk.Button(form, text=ext, command=func)
            ext.grid(column=2, row=row, **sty_button)
    return label, entry, ext
