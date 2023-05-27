import ctypes
import json
import os
import platform
import subprocess
import sys
import threading
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
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
        print("task failed to save to", path)

def load_task(path, vars):
    print("task loading from", path)
    try:
        with open(path) as io:
            data = json.load(io)
        for k, v in vars.items():
            if k in data: v.set(data[k])
    except:
        print("task failed to load from", path)

class Task:
    name = None
    path = None
    vars_spec = {}
    vars = {}

    btn_load = None
    btn_save = None
    btn_run = None
    btn_stop = None

    handles = []
    running = False
    skip_rest = False

    def __init__(self, name, vars_spec={}, vars=None, path=None):
        self.name = name
        self.vars_spec = vars_spec
        self.vars = {k: v["type"](value=v["value"]) for k, v in vars_spec.items()} if vars is None else vars
        self.path = path
        # load autosave
        if self.path is not None: load_task(os.path.join(self.path, f"{self.name}.task"), self.vars)

    def load(self):
        path = filedialog.askopenfilename(filetypes=(("Configuration", "*.task"), ("All", "*.*")))
        if len(path) > 0: load_task(path, self.vars)

    def save(self):
        if self.path is not None: # autosave
            save_task(os.path.join(self.path, f"{self.name}.task"),
                {k: v for k, v in self.vars.items() if k in self.vars_spec and v.get() != self.vars_spec[k]["value"]},
            )
        path = self.vars["out"].get()
        if len(path) > 0:
            os.makedirs(path, exist_ok=True)
            save_task(os.path.join(path, f"{self.name}.task"), self.vars)
        else:
            print("`Output Directory` is required")

    def run(self, job):
        if self.btn_run is not None: self.btn_run.config(state="disabled")
        self.running = True
        self.skip_rest = False
        self.save()
        job()
        self.running = False
        if self.btn_run is not None: self.btn_run.config(state="normal")

    def stop(self):
        self.skip_rest = True
        for job in self.handles:
            if job.poll() is None:
                job.terminate()
        self.running = False
        self.handles.clear()
        self.btn_run.config(state="normal")
        print(f"{self.name} stopped.")

    def call(self, *cmd):
        run_cmd(cmd, self.handles, self.skip_rest)

    def init_ctrl(self, widget, job):
        self.btn_load = ttk.Button(widget, text="Load Task", command=self.load)
        self.btn_save = ttk.Button(widget, text="Save Task", command=self.save)
        self.btn_run = ttk.Button(widget, text="Run Task", command=lambda: threading.Thread(target=self.run, args=(job,)).start())
        self.btn_stop = ttk.Button(widget, text="Stop Task", command=lambda: threading.Thread(target=self.stop).start())
        for b in [self.btn_load, self.btn_save, self.btn_run, self.btn_stop]:
            b.pack(side="left", padx=16, pady=8)
        return widget

# UI
def bind_exit(win, mods):
    def f():
        if (not any([m.task.running for m in mods]) or
            messagebox.askokcancel("Quit", "Task running. Quit now?")):
            [m.task.stop() for m in mods]
            win.destroy()
    win.protocol("WM_DELETE_WINDOW", f)

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

def add_headline(weight, url):
    var = tk.StringVar()
    threading.Thread(target=lambda: show_headline(var, url)).start()
    return ttk.Label(weight, textvariable=var, justify="center"), var

def add_console(weight):
    console = tk.Text(weight, height=12, state="disabled")
    sys.stdout = Console(console)
    sys.stderr = Console(console)
    return console

def init_form(f):
    ttk.Label(f, width=20 if is_windows else 16).grid(column=0, row=0)
    ttk.Label(f, width=80 if is_windows else 60).grid(column=1, row=0)
    ttk.Label(f, width=12 if is_windows else 10).grid(column=2, row=0)
    return f

sty_label = {"sticky": "W", "padx": 4, "pady": 4}
sty_entry = {"sticky": "EW", "padx": 0, "pady": 1}
sty_button = {"sticky": "EW", "padx": 4, "pady": 1}
sty_unit = {"sticky": "EW", "padx": 0, "pady": 1}
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

def askfile(var, out=None, **kwargs):
    def f():
        path = filedialog.askopenfilename(**kwargs)
        if len(path) == 0: return None
        var.set(path)
        if out is not None and len(out.get()) == 0:
            out.set(os.path.join(os.path.dirname(path), "out"))
    return f

def askdir(var, out=None, **kwargs):
    def f():
        path = filedialog.askdirectory(**kwargs)
        if len(path) == 0: return None
        var.set(path)
        if out is not None and len(out.get()) == 0:
            out.set(os.path.join(path, "out"))
    return f

def askfiles(var, out=None, **kwargs):
    def f():
        paths = filedialog.askopenfilenames(**kwargs)
        if len(paths) == 0:
            return None
        elif len(paths) > 1:
            print("multiple files selected:")
            for file in paths: print(">>", file)
        var.set(";".join(paths))
        if len(var.get()) > 0 and out is not None and len(out.get()) == 0:
            out.set(os.path.join(os.path.dirname(paths[0]), "out"))
    return f
