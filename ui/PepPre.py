import threading
import tkinter as tk
from tkinter import ttk

import ttkbootstrap

import meta
import util

main = ttk.Frame(meta.win)
main.pack(padx=16, pady=8)
var = tk.StringVar()
threading.Thread(target=lambda: util.show_headline(var, meta.server)).start()
ttk.Label(main, textvariable=var, justify="center").pack()
notebook = ttk.Notebook(main)
notebook.pack(fill="x")
util.add_console(main).pack(fill="x")
ttk.Label(main, text=meta.copyright, justify="center").pack()

import PepPreIsolated, PepPreGlobal, PepPreAlign, PepPreView, extra, help
notebook.add(PepPreIsolated.main, text="Isolated Precursor")
notebook.add(PepPreGlobal.main, text="Global Precursor")
notebook.add(PepPreAlign.main, text="Precursor Alignment")
notebook.add(PepPreView.main, text="Visualization")
notebook.add(extra.main, text="Extra Configuration")
notebook.add(help.main, text="Help")

util.bind_exit(meta.win, [PepPreIsolated, PepPreView])
util.center_window(meta.win)
tk.mainloop()
