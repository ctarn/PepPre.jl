import os
import sys
import threading
import tkinter as tk
from tkinter import ttk, scrolledtext

import ttkbootstrap

import meta
import util

os.makedirs(meta.homedir, exist_ok=True)

pos = [0.0, 0.0]
win = util.create_window(pos)

main = ttk.Frame(win)
main.grid(column=0, row=0, padx=16, pady=8)

row = 0
# headline
row += 1

notebook = ttk.Notebook(main)
notebook.grid(column=0, row=row, sticky="WE")
row += 1

console = scrolledtext.ScrolledText(main, height=16, state="disabled")
console.grid(column=0, row=row, sticky="WE")
row += 1
ttk.Label(main, text=meta.copyright, justify="center").grid(column=0, row=row)

sys.stdout = util.Console(console)
sys.stderr = util.Console(console)
if getattr(sys, 'frozen', False):
    threading.Thread(target=lambda: util.show_headline(meta.server, main)).start()

import PepPreMain
notebook.add(PepPreMain.main, text="PepPre")

import PepPreView
notebook.add(PepPreView.main, text="PepPreView")

def on_exit():
    if (not (PepPreMain.running or PepPreView.running)) or tk.messagebox.askokcancel("Quit", "Task running. Quit now?"):
        PepPreMain.do_stop()
        PepPreView.do_stop()
        win.destroy()

ttk.Button(main, text="×", command=on_exit).grid(column=1, row=0, sticky="E")

util.center_window(win)

tk.mainloop()
