import os
from tkinter import ttk

import meta
import util

main = ttk.Frame()
main.pack(fill="both")

V = meta.vars
path = os.path.join(meta.homedir, "extra.cfg")

util.init_form(main)
I = 0
util.add_entry(main, I, "PepPreIsolated:", V["peppreisolated"], "Select", util.askfile(V["peppreisolated"]))
I += 1
util.add_entry(main, I, "PepPreGlobal:", V["peppreglobal"], "Select", util.askfile(V["peppreglobal"]))
I += 1
util.add_entry(main, I, "PepPreAlign:", V["pepprealign"], "Select", util.askfile(V["pepprealign"]))
I += 1
util.add_entry(main, I, "PepPreView:", V["peppreview"], "Select", util.askfile(V["peppreview"]))
I += 1
util.add_entry(main, I, "ThermoRawRead:", V["thermorawread"], "Select", util.askfile(V["thermorawread"]))
I += 1
if not util.is_windows:
    util.add_entry(main, I, "Mono Runtime:", V["monoruntime"], "Select", util.askfile(V["monoruntime"]))
    I += 1
if util.is_windows:
    util.add_entry(main, I, "MsConvert:", V["msconvert"], "Select", util.askfile(V["msconvert"]))
    I += 1
util.add_entry(main, I, "pFind Directory:", V["cfg"], "Select", util.askdir(V["cfg"]))
I += 1
f = ttk.Frame(main)
f.grid(column=0, row=I, columnspan=3)
ttk.Button(f, text="Load Configuration", command=lambda: util.load_task(path, V)).pack(side="left", padx=16, pady=8)
ttk.Button(f, text="Save Configuration", command=lambda: util.save_task(path, V)).pack(side="left", padx=16, pady=8)
util.load_task(path, V)
