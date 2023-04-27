import os
import threading
import tkinter as tk
from tkinter import ttk, filedialog

import meta
import util

handles = []
running = False
skip_rest = False

path_autosave = os.path.join(meta.homedir, "autosave.task")

footnote = """
Note:
⧫ Please try something like `Ctrl + A` to select multiple data files.
⧫ For .ms2 files, corresponding .ms1 files should be in the same directory.
⧫ `IPV` (isotopic pattern vectors) can be automatically generated and cached to specified path.
⧫ `Isolation Width` can be set as `auto` if .raw files are provided or using .ms2 files containing `IsolationWidth` line.
⧫ Free feel to contact me if you have any questions :).
"""

main = ttk.Frame()

if util.is_darwin:
    path_mono = "/Library/Frameworks/Mono.framework/Versions/Current/Commands/mono"
else:
    path_mono = "mono"

fmts = ["csv", "tsv", "ms2", "mgf"]
vars_spec = {
    "data": {"type": tk.StringVar, "value": ""},
    "ipv": {"type": tk.StringVar, "value": os.path.join(meta.homedir, "IPV.bson")},
    "width": {"type": tk.StringVar, "value": "2.0"},
    "charge_min": {"type": tk.StringVar, "value": "2"},
    "charge_max": {"type": tk.StringVar, "value": "6"},
    "error": {"type": tk.StringVar, "value": "10.0"},
    "exclusion": {"type": tk.StringVar, "value": "1.0"},
    "fold": {"type": tk.StringVar, "value": "4.0"},
    "inst": {"type": tk.IntVar, "value": 0},
    "fmt_csv": {"type": tk.IntVar, "value": 1},
    "fmt_tsv": {"type": tk.IntVar, "value": 0},
    "fmt_ms2": {"type": tk.IntVar, "value": 0},
    "fmt_mgf": {"type": tk.IntVar, "value": 0},
    "out": {"type": tk.StringVar, "value": ""},
    "peppre": {"type": tk.StringVar, "value": util.get_content("PepPre", "bin", "PepPre")},
    "thermorawread": {"type": tk.StringVar, "value": util.get_content("ThermoRawRead", "ThermoRawRead.exe", shared=True)},
    "mono": {"type": tk.StringVar, "value": path_mono},
    "msconvert": {"type": tk.StringVar, "value": util.get_content("ProteoWizard", "msconvert")},
}
vars = {k: v["type"](value=v["value"]) for k, v in vars_spec.items()}
util.load_task(path_autosave, vars)

row = 0
ttk.Label(main, width=20 if util.is_windows else 16).grid(column=0, row=row)
ttk.Label(main, width=80 if util.is_windows else 60).grid(column=1, row=row)

def do_select_data():
    if util.is_windows: filetypes = (("All", "*.*"),)
    else: filetypes = (("MS2", "*.ms2"), ("RAW", "*.raw"), ("All", "*.*"))
    files = filedialog.askopenfilenames(filetypes=filetypes)
    if len(files) == 0:
        return None
    elif len(files) > 1:
        print("multiple data selected:")
        for file in files: print(">>", file)
    vars["data"].set(";".join(files))
    if len(vars["data"].get()) > 0 and len(vars["out"].get()) == 0:
        vars["out"].set(os.path.join(os.path.dirname(files[0]), "out"))

ttk.Label(main, text="Data:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["data"]).grid(column=1, row=row, sticky="WE")
ttk.Button(main, text="Select", command=do_select_data).grid(column=2, row=row, sticky="W")
row += 1

def do_select_ipv():
    path = filedialog.askopenfilename(filetypes=(("IPV", "*.bson"), ("All", "*.*")))
    if len(path) > 0: vars["ipv"].set(path)

ttk.Label(main, text="IPV:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["ipv"]).grid(column=1, row=row, sticky="WE")
ttk.Button(main, text="Select", command=do_select_ipv).grid(column=2, row=row, sticky="W")
row += 1

ttk.Label(main, text="Isolation Width:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["width"]).grid(column=1, row=row, sticky="WE")
ttk.Label(main, text="Th").grid(column=2, row=row, sticky="W")
row += 1

ttk.Label(main, text="Charge Range:").grid(column=0, row=row, sticky="W")
frm_charge = ttk.Frame(main)
frm_charge.grid(column=1, row=row, sticky="WE")
ttk.Entry(frm_charge, textvariable=vars["charge_min"]).grid(column=0, row=0, sticky="WE")
ttk.Label(frm_charge, text=" - ").grid(column=1, row=0, sticky="WE")
ttk.Entry(frm_charge, textvariable=vars["charge_max"]).grid(column=2, row=0, sticky="WE")
row += 1

ttk.Label(main, text="Mass Error:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["error"]).grid(column=1, row=row, sticky="WE")
ttk.Label(main, text="ppm").grid(column=2, row=row, sticky="W")
row += 1

ttk.Label(main, text="Exclusion Threshold:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["exclusion"]).grid(column=1, row=row, sticky="WE")
row += 1

ttk.Label(main, text="Precursor Number:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["fold"]).grid(column=1, row=row, sticky="WE")
ttk.Label(main, text="fold").grid(column=2, row=row, sticky="W")
row += 1

ttk.Label(main, text="Original Precursor:").grid(column=0, row=row, sticky="W")
ttk.Checkbutton(main, text="Preserve", variable=vars["inst"]).grid(column=1, row=row)
row += 1

ttk.Label(main, text="Output Format:").grid(column=0, row=row, sticky="W")
frm_format = ttk.Frame(main)
frm_format.grid(column=1, row=row)
for i, fmt in enumerate(fmts):
    ttk.Checkbutton(frm_format, text=fmt.upper(), variable=vars[f"fmt_{fmt}"]).grid(column=i, row=0)
row += 1

def do_select_out():
    path = filedialog.askdirectory()
    if len(path) > 0: vars["out"].set(path)

ttk.Label(main, text="Output Directory:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["out"]).grid(column=1, row=row, sticky="WE")
ttk.Button(main, text="Select", command=do_select_out).grid(column=2, row=row, sticky="W")
row += 1

def run_thermorawread(data, out):
    cmd = [vars["thermorawread"].get(), data, out]
    if not util.is_windows:
        cmd = [vars["mono"].get()] + cmd
    util.run_cmd(cmd, handles, skip_rest)
    return os.path.join(out, os.path.splitext(os.path.basename(data))[0] + ".ms2")

def run_msconvert(data, out):
    cmd = [vars["msconvert"].get(), "--ms1", "--filter", "peakPicking true", "-o", out, data]
    util.run_cmd(cmd, handles, skip_rest)
    cmd = [vars["msconvert"].get(), "--ms2", "--filter", "peakPicking true", "-o", out, data]
    util.run_cmd(cmd, handles, skip_rest)
    return os.path.join(out, os.path.splitext(os.path.basename(data))[0] + ".ms2")

def run_peppre(path):
    cmd = [
        vars["peppre"].get(),
        *(["--inst"] if vars["inst"].get() else []),
        "--ipv", vars["ipv"].get(),
        "--width", vars["width"].get(),
        "--charge", vars["charge_min"].get() + ":" + vars["charge_max"].get(),
        "--error", vars["error"].get(),
        "--thres", vars["exclusion"].get(),
        "--fold", vars["fold"].get(),
        "--fmt", ",".join(filter(lambda x: vars[f"fmt_{x}"].get(), fmts)),
        "--out", vars["out"].get(),
        path,
    ]
    util.run_cmd(cmd, handles, skip_rest)

def do_load():
    path = filedialog.askopenfilename(filetypes=(("Configuration", "*.task"), ("All", "*.*")))
    if len(path) > 0: util.load_task(path)

def do_save():
    util.save_task(path_autosave, {k: v for k, v in vars.items() if v.get() != vars_spec[k]["value"]})
    path = vars["out"].get()
    if len(path) > 0:
        os.makedirs(path, exist_ok=True)
        util.save_task(os.path.join(path, "PepPre.task"), vars)
    else:
        print("`Output Directory` is required")

def do_run():
    btn_run.config(state="disabled")
    global handles, running, skip_rest
    running = True
    skip_rest = False
    do_save()
    for p in vars["data"].get().split(";"):
        ext = os.path.splitext(p)[1].lower()
        if ext == ".ms2":
            pass
        elif ext == ".ms1":
            print("ERROR: select MS2 files instead of MS1 files.")
            break
        elif ext == ".raw":
            p = run_thermorawread(p, vars["out"].get())
        elif util.is_windows:
            p = run_msconvert(p, vars["out"].get())
        else:
            print("WARN: file not supported and skipped, path =", p)
            continue
        run_peppre(p)
    running = False
    btn_run.config(state="normal")

def do_stop():
    global handles, running, skip_rest
    skip_rest = True
    for job in handles:
        if job.poll() is None:
            job.terminate()
    running = False
    handles.clear()
    btn_run.config(state="normal")
    print("PepPre stopped.")

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

def do_select_peppre():
    path = filedialog.askopenfilename()
    if len(path) > 0: vars["peppre"].set(path)

ttk.Label(main, text="PepPre:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["peppre"]).grid(column=1, row=row, sticky="WE")
ttk.Button(main, text="Select", command=do_select_peppre).grid(column=2, row=row, sticky="W")
row += 1

def do_select_thermorawread():
    path = filedialog.askopenfilename()
    if len(path) > 0: vars["thermorawread"].set(path)

ttk.Label(main, text="ThermoRawRead:").grid(column=0, row=row, sticky="W")
ttk.Entry(main, textvariable=vars["thermorawread"]).grid(column=1, row=row, sticky="WE")
ttk.Button(main, text="Select", command=do_select_thermorawread).grid(column=2, row=row, sticky="W")
row += 1

def do_select_mono():
    path = filedialog.askopenfilename()
    if len(path) > 0: vars["mono"].set(path)

if not util.is_windows:
    ttk.Label(main, text="Mono Runtime:").grid(column=0, row=row, sticky="W")
    ttk.Entry(main, textvariable=vars["mono"]).grid(column=1, row=row, sticky="WE")
    ttk.Button(main, text="Select", command=do_select_mono).grid(column=2, row=row, sticky="W")
row += 1

def do_select_msconvert():
    path = filedialog.askopenfilename()
    if len(path) > 0: vars["msconvert"].set(path)

if util.is_windows:
    ttk.Label(main, text="MsConvert:").grid(column=0, row=row, sticky="W")
    ttk.Entry(main, textvariable=vars["msconvert"]).grid(column=1, row=row, sticky="WE")
    ttk.Button(main, text="Select", command=do_select_msconvert).grid(column=2, row=row, sticky="W")
    row += 1

ttk.Label(main, text=footnote, justify="left").grid(column=0, row=row, columnspan=3, sticky="WE")
