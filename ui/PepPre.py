import os
import sys
import threading
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext

import ttkbootstrap

import meta
import util

os.makedirs(meta.homedir, exist_ok=True)

win = tk.Tk()
win.title(meta.name)
win.iconphoto(True, tk.PhotoImage(file=util.get_content(f"{meta.name}.png", shared=True)))
win.resizable(False, False)
util.center_window(win)

main = ttk.Frame(win)
main.pack(padx=16, pady=8)

headline = tk.StringVar()
ttk.Label(main, textvariable=headline, justify="center").pack()

notebook = ttk.Notebook(main)
notebook.pack(fill="x")

console = scrolledtext.ScrolledText(main, height=16, state="disabled")
console.pack(fill="x")

ttk.Label(main, text=meta.copyright, justify="center").pack()

sys.stdout = util.Console(console)
sys.stderr = util.Console(console)

threading.Thread(target=lambda: util.show_headline(headline, meta.server)).start()

import PepPreMain
notebook.add(PepPreMain.main, text="PepPre")

import PepPreView
notebook.add(PepPreView.main, text="PepPreView")

def on_exit():
    if (not any([PepPreMain.running, PepPreView.running]) or
        messagebox.askokcancel("Quit", "Task running. Quit now?")):
        PepPreMain.do_stop()
        PepPreView.do_stop()
        win.destroy()

win.protocol("WM_DELETE_WINDOW", on_exit)

util.center_window(win)

tk.mainloop()
