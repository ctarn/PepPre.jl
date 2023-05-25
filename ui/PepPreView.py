import os
import random
import threading
import tkinter as tk
from tkinter import ttk, filedialog

import meta
import util

handles = []
running = False
skip_rest = False

path_autosave = os.path.join(meta.homedir, "autosave_view.task")

footnote = """
Note:
⧫ A web page will be opened in the default browser automatically after clicking `Run Task`.
  Otherwise, you can open the web page manually by visiting above URL in your browser.
⧫ Most error messages can be safely ignored if the web page is updated as you clicking.
⧫ Please click `New Port` and re-run the task if you see the error message `address already in use`.
⧫ The `Output Directory` is only used to store saved task.
⧫ Please configure `pFind Directory` if you want to use customized pFind settings.
  The path should be `C:\\pFindStudio\\pFind3\\bin` by default on Windows.
"""

main = ttk.Frame()
main.pack(fill="both")

vars_spec = {
    "data": {"type": tk.StringVar, "value": ""},
    "ipv": {"type": tk.StringVar, "value": os.path.join(meta.homedir, "IPV.bson")},
    "psm": {"type": tk.StringVar, "value": ""},
    "out": {"type": tk.StringVar, "value": ""},
    "peppreview": {"type": tk.StringVar, "value": util.get_content("PepPre", "bin", "PepPreView")},
    "cfg": {"type": tk.StringVar, "value": ""},
    "url": {"type": tk.StringVar, "value": "127.0.0.1:30030"},
}
vars = {k: v["type"](value=v["value"]) for k, v in vars_spec.items()}
util.load_task(path_autosave, vars)

row = 0
util.init_form(main)

def do_select_data():
    filetypes = (("MS2", "*.ms2"), ("All", "*.*"))
    files = filedialog.askopenfilenames(filetypes=filetypes)
    if len(files) == 0:
        return None
    elif len(files) > 1:
        print("multiple data selected:")
        for file in files: print(">>", file)
    vars["data"].set(";".join(files))
    if len(vars["data"].get()) > 0 and len(vars["out"].get()) == 0:
        vars["out"].set(os.path.join(os.path.dirname(files[0]), "out"))

util.add_entry(main, row, "MS Data:", vars["data"], "Select", do_select_data)
row += 1

t = (("IPV", "*.bson"), ("All", "*.*"))
util.add_entry(main, row, "IPV:", vars["ipv"], "Select", util.askfile(vars["ipv"], filetypes=t))
row += 1

t = (("pFind Spectra File", "*.spectra"), ("All", "*.*"))
util.add_entry(main, row, "PSM:", vars["psm"], "Select", util.askfile(vars["psm"], filetypes=t))
row += 1

util.add_entry(main, row, "Output Directory:", vars["out"], "Select", util.askdir(vars["out"]))
row += 1

def run_peppreview(paths):
    cmd = [
        vars["peppreview"].get(),
        "--ipv", vars["ipv"].get(),
        "--psm", vars["psm"].get(),
        "--cfg", vars["cfg"].get(),
        "--host", vars["url"].get().split(":")[0],
        "--port", vars["url"].get().split(":")[1],
        *paths,
    ]
    util.run_cmd(cmd, handles, skip_rest)

def do_load():
    path = filedialog.askopenfilename(filetypes=(("Configuration", "*.task"), ("All", "*.*")))
    if len(path) > 0: util.load_task(path, vars)

def do_autosave():
    util.save_task(path_autosave, {k: v for k, v in vars.items() if v.get() != vars_spec[k]["value"]})

def do_save():
    do_autosave()
    path = vars["out"].get()
    if len(path) > 0:
        os.makedirs(path, exist_ok=True)
        util.save_task(os.path.join(path, "PepPreView.task"), vars)
    else:
        print("`Output Directory` is required")

def do_run():
    btn_run.config(state="disabled")
    global handles, running, skip_rest
    running = True
    skip_rest = False
    do_autosave()
    paths = vars["data"].get().split(";")
    run_peppreview(paths)
    running = False
    btn_run.config(state="normal")

def do_stop():
    global handles, running, skip_rest
    running = False
    skip_rest = True
    for job in handles:
        if job.poll() is None:
            job.terminate()
    handles.clear()
    btn_run.config(state="normal")
    print("PepPreView stopped.")

frm_btn = ttk.Frame(main)
frm_btn.grid(column=0, row=row, columnspan=3)
ttk.Button(frm_btn, text="Load Task", command=do_load).grid(column=0, row=0, padx=16, pady=8)
ttk.Button(frm_btn, text="Save Task", command=do_save).grid(column=1, row=0, padx=16, pady=8)
btn_run = ttk.Button(frm_btn, text="Run Task", command=lambda: threading.Thread(target=do_run).start())
btn_run.grid(column=2, row=0, padx=16, pady=8)
ttk.Button(frm_btn, text="Stop Task", command=lambda: threading.Thread(target=do_stop).start()).grid(column=3, row=0, padx=16, pady=8)
row += 1

ttk.Separator(main, orient=tk.HORIZONTAL).grid(column=0, row=row, columnspan=3, sticky="EW")
ttk.Label(main, text="Advanced Configuration").grid(column=0, row=row, columnspan=3)
row += 1

util.add_entry(main, row, "PepPreView:", vars["peppreview"], "Select", util.askfile(vars["peppreview"]))
row += 1

util.add_entry(main, row, "pFind Directory:", vars["cfg"], "Select", util.askdir(vars["cfg"]))
row += 1

def new_port():
    p = str(random.randint(49152, 65535))
    host = vars["url"].get().split(":")[0]
    vars["url"].set(host + ":" + p)

new_port()
util.add_entry(main, row, "URL:", vars["url"], "New Port", new_port)
row += 1

ttk.Label(main, text=footnote, justify="left").grid(column=0, row=row, columnspan=3, sticky="EW")
