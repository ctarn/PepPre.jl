import os
import tkinter as tk
from tkinter import ttk

import meta
import util

footnote = """
Note:
⧫ The `IPV` (isotopic pattern vectors) can be automatically generated and cached to specified path.
⧫ Select multiple data files using something like `Ctrl + A`.
⧫ Free feel to contact me if you have any questions :).
"""

main = ttk.Frame()
main.pack(fill="both")

vars_spec = {
    "data": {"type": tk.StringVar, "value": ""},
    "out": {"type": tk.StringVar, "value": ""},
    "ipv": {"type": tk.StringVar, "value": os.path.join(meta.homedir, "peptide.ipv")},
    "peak": {"type": tk.StringVar, "value": "4000"},
    "charge_min": {"type": tk.StringVar, "value": "2"},
    "charge_max": {"type": tk.StringVar, "value": "6"},
    "error": {"type": tk.StringVar, "value": "10.0"},
    "exclusion": {"type": tk.StringVar, "value": "1.0"},
    "gap": {"type": tk.StringVar, "value": "16"},
    "proc": {"type": tk.StringVar, "value": "4"},
}
task = util.Task("PepPreGlobal", vars_spec, path=meta.homedir, shared_vars_spec=meta.vars_spec, shared_vars=meta.vars)
V = task.vars

def run_thermorawread(data, out):
    task.call(*([] if util.is_windows else [V["mono"].get()]), V["thermorawread"].get(), "mes", data, out)
    return os.path.join(out, os.path.splitext(os.path.basename(data))[0] + ".mes")

def run():
    paths = []
    for p in V["data"].get().split(";"):
        ext = os.path.splitext(p)[1].lower()
        if ext == ".raw": p = run_thermorawread(p, V["out"].get())
        paths.append(p)
    task.call(V["peppreglobal"].get(), *paths, "--out", V["out"].get(),
        "--ipv", V["ipv"].get(),
        "--peak", V["peak"].get(),
        "--charge", V["charge_min"].get() + ":" + V["charge_max"].get(),
        "--error", V["error"].get(),
        "--thres", V["exclusion"].get(),
        "--gap", V["gap"].get(),
        "--proc", V["proc"].get(),
    )

util.init_form(main)
I = 0
t = (("MES", "*.mes"), ("MS1", "*.ms1"), ("RAW", "*.raw"), ("All", "*.*"))
util.add_entry(main, I, "MS Data:", V["data"], "Select", util.askfiles(V["data"], V["out"], filetypes=t))
I += 1
t = (("IPV", "*.ipv"), ("All", "*.*"))
util.add_entry(main, I, "Isotope Pattern:", V["ipv"], "Select", util.askfile(V["ipv"], filetypes=t))
I += 1
util.add_entry(main, I, "Num. of Peaks:", V["peak"], "per scan")
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
util.add_entry(main, I, "Max. Scan Gap:", V["gap"])
I += 1
util.add_entry(main, I, "Parallelization:", V["proc"])
I += 1
util.add_entry(main, I, "Output Directory:", V["out"], "Select", util.askdir(V["out"]))
I += 1
task.init_ctrl(ttk.Frame(main), run).grid(column=0, row=I, columnspan=3)
I += 1
ttk.Label(main, text=footnote, justify="left").grid(column=0, row=I, columnspan=3, sticky="EW")
