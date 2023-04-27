import os
import sys
import threading
import tkinter as tk
from tkinter import ttk, scrolledtext

import ttkbootstrap

import meta
import util

os.makedirs(meta.homedir, exist_ok=True)

win = tk.Tk()
win.title(meta.name)
win.iconphoto(True, tk.PhotoImage(file=util.get_content(f"{meta.name}.png", shared=True)))
win.resizable(False, False)
win.overrideredirect(True)
util.center_window(win)

x_win, y_win = 0, 0

def on_click(e):
    global x_win, y_win
    x_win, y_win = e.x, e.y

def on_drag(e):
    win.geometry(f"+{e.x_root - x_win}+{e.y_root - y_win}")

win.bind("<Button-1>", on_click)
win.bind("<B1-Motion>", on_drag)

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
