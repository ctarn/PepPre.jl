import os
import tkinter as tk
from tkinter import ttk

import meta
import util

main = ttk.Frame()
main.pack(fill="both")

fmts = ["csv", "tsv", "ms2", "mgf", "pf2"]
vars_spec = {
    "data": {"type": tk.StringVar, "value": ""},
    "out": {"type": tk.StringVar, "value": ""},
    "ipv": {"type": tk.StringVar, "value": os.path.join(meta.homedir, "peptide.ipv")},
    "width": {"type": tk.StringVar, "value": "2.0"},
    "charge_min": {"type": tk.StringVar, "value": "2"},
    "charge_max": {"type": tk.StringVar, "value": "6"},
    "error": {"type": tk.StringVar, "value": "10.0"},
    "exclusion": {"type": tk.StringVar, "value": "1.0"},
    "fold": {"type": tk.StringVar, "value": "4.0"},
    "inst": {"type": tk.IntVar, "value": 0},
}
for fmt in fmts: vars_spec[f"fmt_{fmt}"] = {"type": tk.IntVar, "value": fmt in ["csv"]}
task = util.Task("PepPreIsolated", vars_spec, path=meta.homedir, shared_vars_spec=meta.vars_spec, shared_vars=meta.vars)
V = task.vars

def run_thermorawread(data, out):
    task.call(*([] if util.is_windows else [V["monoruntime"].get()]), V["thermorawread"].get(), "mes", data, out)
    return os.path.join(out, os.path.splitext(os.path.basename(data))[0] + ".mes")

def run_msconvert(data, out):
    task.call(V["msconvert"].get(), "--ms1", "--filter", "peakPicking true", "-o", out, data)
    task.call(V["msconvert"].get(), "--ms2", "--filter", "peakPicking true", "-o", out, data)
    return os.path.join(out, os.path.splitext(os.path.basename(data))[0] + ".ms2")

def run():
    paths = []
    for p in V["data"].get().split(";"):
        ext = os.path.splitext(p)[1].lower()
        if ext == ".mes":
            pass
        elif ext == ".ms2":
            pass
        elif ext == ".ms1":
            print("ERROR: select MS2 files instead of MS1 files.")
            break
        elif ext == ".raw":
            p = run_thermorawread(p, V["out"].get())
        elif util.is_windows:
            p = run_msconvert(p, V["out"].get())
        else:
            print("WARN: file not supported and skipped, path =", p)
            continue
        paths.append(p)
    task.call(V["peppreisolated"].get(), *paths, "--out", V["out"].get(),
        "--ipv", V["ipv"].get(),
        "--width", V["width"].get(),
        "--charge", V["charge_min"].get() + ":" + V["charge_max"].get(),
        "--error", V["error"].get(),
        "--thres", V["exclusion"].get(),
        "--fold", V["fold"].get(),
        *(["--inst"] if V["inst"].get() else []),
        "--fmt", ",".join(filter(lambda x: V[f"fmt_{x}"].get(), fmts)),
    )

util.init_form(main)
I = 0
t = (("MES", "*.mes"), ("MS2", "*.ms2"), ("RAW", "*.raw"), ("All", "*.*"))
util.add_entry(main, I, "MS Data:", V["data"], "Select", util.askfiles(V["data"], V["out"], filetypes=t))
I += 1
t = (("IPV", "*.ipv"), ("All", "*.*"))
util.add_entry(main, I, "Isotope Pattern:", V["ipv"], "Select", util.askfile(V["ipv"], filetypes=t))
I += 1
util.add_entry(main, I, "Isolation Width:", V["width"], "Th")
I += 1
_, f, _ = util.add_entry(main, I, "Charge Range:", ttk.Frame(main))
ttk.Entry(f, textvariable=V["charge_min"]).pack(side="left", fill="x", expand=True)
ttk.Label(f, text="-").pack(side="left")
ttk.Entry(f, textvariable=V["charge_max"]).pack(side="left", fill="x", expand=True)
I += 1
util.add_entry(main, I, "Max. Mass Error:", V["error"], "ppm")
I += 1
util.add_entry(main, I, "Exclusion Threshold:", V["exclusion"])
I += 1
util.add_entry(main, I, "Precursor Number:", V["fold"], "fold")
I += 1
_, f, _ =  util.add_entry(main, I, "Oringinal Precursor:", ttk.Frame(main))
ttk.Checkbutton(f, text="Preserve", variable=V["inst"]).pack(side="left", expand=True)
I += 1
_, f, _ = util.add_entry(main, I, "Output Format", ttk.Frame(main))
for x in fmts: ttk.Checkbutton(f, text=x.upper(), variable=V[f"fmt_{x}"]).pack(side="left", expand=True)
I += 1
util.add_entry(main, I, "Output Directory:", V["out"], "Select", util.askdir(V["out"]))
I += 1
task.init_ctrl(ttk.Frame(main), run).grid(column=0, row=I, columnspan=3)
