import tkinter as tk
from tkinter import ttk

import ttkbootstrap

import meta
import util

main = ttk.Frame(meta.win)
main.pack(padx=16, pady=8)
util.add_headline(main, meta.server)[0].pack()
notebook = ttk.Notebook(main)
notebook.pack(fill="x")
util.add_console(main).pack(fill="x")
ttk.Label(main, text=meta.copyright, justify="center").pack()

import PepPreIsolated, PepPreView, citation, extra
notebook.add(PepPreIsolated.main, text="Isolated Precursor")
notebook.add(PepPreView.main, text="Visualization")
notebook.add(citation.main, text="Citation")
notebook.add(extra.main, text="Extra Configuration")

util.bind_exit(meta.win, [PepPreIsolated, PepPreView])
util.center_window(meta.win)
tk.mainloop()
