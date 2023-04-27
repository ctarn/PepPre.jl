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
main.grid(sticky="SNWE")

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
ttk.Label(main, width=20 if util.is_windows else 16).grid(column=0, row=row)
ttk.Label(main, width=80 if util.is_windows else 60).grid(column=1, row=row)
ttk.Label(main, width=12 if util.is_windows else 10).grid(column=2, row=row)

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

ttk.Label(main, text="MS Data:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["data"]).grid(column=1, row=row, **util.sty_entry)
ttk.Button(main, text="Select", command=do_select_data).grid(column=2, row=row, **util.sty_button)
row += 1

def do_select_ipv():
    path = filedialog.askopenfilename(filetypes=(("IPV", "*.bson"), ("All", "*.*")))
    if len(path) > 0: vars["ipv"].set(path)

ttk.Label(main, text="IPV:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["ipv"]).grid(column=1, row=row, **util.sty_entry)
ttk.Button(main, text="Select", command=do_select_ipv).grid(column=2, row=row, **util.sty_button)
row += 1

def do_select_psm():
    path = filedialog.askopenfilename(filetypes=(("pFind Spectra File", "*.spectra"), ("All", "*.*")))
    if len(path) > 0: vars["psm"].set(path)

ttk.Label(main, text="PSM:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["psm"]).grid(column=1, row=row, **util.sty_entry)
ttk.Button(main, text="Select", command=do_select_psm).grid(column=2, row=row, **util.sty_button)
row += 1

def do_select_pfind():
    path = filedialog.askdirectory()
    if len(path) > 0: vars["out"].set(path)

ttk.Label(main, text="Output Directory:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["out"]).grid(column=1, row=row, **util.sty_entry)
ttk.Button(main, text="Select", command=do_select_pfind).grid(column=2, row=row, **util.sty_button)
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

ttk.Separator(main, orient=tk.HORIZONTAL).grid(column=0, row=row, columnspan=3, sticky="WE")
ttk.Label(main, text="Advanced Configuration").grid(column=0, row=row, columnspan=3)
row += 1

def do_select_peppreview():
    path = filedialog.askopenfilename()
    if len(path) > 0: vars["peppreview"].set(path)

ttk.Label(main, text="PepPreView:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["peppreview"]).grid(column=1, row=row, **util.sty_entry)
ttk.Button(main, text="Select", command=do_select_peppreview).grid(column=2, row=row, **util.sty_button)
row += 1

def do_select_pfind():
    path = filedialog.askdirectory()
    if len(path) > 0: vars["cfg"].set(path)

ttk.Label(main, text="pFind Directory:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["cfg"]).grid(column=1, row=row, **util.sty_entry)
ttk.Button(main, text="Select", command=do_select_pfind).grid(column=2, row=row, **util.sty_button)
row += 1

def do_new_port():
    p = str(random.randint(49152, 65535))
    host = vars["url"].get().split(":")[0]
    vars["url"].set(host + ":" + p)

do_new_port()
ttk.Label(main, text="URL:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["url"]).grid(column=1, row=row, **util.sty_entry)
ttk.Button(main, text="New Port", command=do_new_port).grid(column=2, row=row, **util.sty_button)
row += 1

ttk.Label(main, text=footnote, justify="left").grid(column=0, row=row, columnspan=3, sticky="WE")
