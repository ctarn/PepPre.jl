import os
import random
import tkinter as tk
from tkinter import ttk

import meta
import util

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
    "out": {"type": tk.StringVar, "value": ""},
    "psm": {"type": tk.StringVar, "value": ""},
    "ipv": {"type": tk.StringVar, "value": os.path.join(meta.homedir, "peptide.ipv")},
    "peppreview": {"type": tk.StringVar, "value": util.get_content("PepPre", "bin", "PepPreView")},
    "cfg": {"type": tk.StringVar, "value": ""},
    "url": {"type": tk.StringVar, "value": "127.0.0.1:30030"},
}
task = util.Task("PepPreView", vars_spec, path=meta.homedir)
V = task.vars

def run():
    task.call(V["peppreview"].get(), *(V["data"].get().split(";")),
        "--psm", V["psm"].get(),
        "--ipv", V["ipv"].get(),
        "--cfg", V["cfg"].get(),
        "--host", V["url"].get().split(":")[0],
        "--port", V["url"].get().split(":")[1],
    )

def new_port():
    p = str(random.randint(49152, 65535))
    host = V["url"].get().split(":")[0]
    V["url"].set(host + ":" + p)

new_port()

util.init_form(main)
I = 0
t = (("MES", "*.mes"), ("MS2", "*.ms2"), ("All", "*.*"))
util.add_entry(main, I, "MS Data:", V["data"], "Select", util.askfiles(V["data"], V["out"], filetypes=t))
I += 1
t = (("pFind Spectra File", "*.spectra"), ("All", "*.*"))
util.add_entry(main, I, "PSM:", V["psm"], "Select", util.askfile(V["psm"], filetypes=t))
I += 1
t = (("IPV", "*.ipv"), ("All", "*.*"))
util.add_entry(main, I, "Isotope Pattern:", V["ipv"], "Select", util.askfile(V["ipv"], filetypes=t))
I += 1
util.add_entry(main, I, "Output Directory:", V["out"], "Select", util.askdir(V["out"]))
I += 1
task.init_ctrl(ttk.Frame(main), run).grid(column=0, row=I, columnspan=3)
I += 1
ttk.Separator(main, orient=tk.HORIZONTAL).grid(column=0, row=I, columnspan=3, sticky="EW")
ttk.Label(main, text="Advanced Configuration").grid(column=0, row=I, columnspan=3)
I += 1
util.add_entry(main, I, "PepPreView:", V["peppreview"], "Select", util.askfile(V["peppreview"]))
I += 1
util.add_entry(main, I, "pFind Directory:", V["cfg"], "Select", util.askdir(V["cfg"]))
I += 1
util.add_entry(main, I, "URL:", V["url"], "New Port", new_port)
I += 1
ttk.Label(main, text=footnote, justify="left").grid(column=0, row=I, columnspan=3, sticky="EW")
