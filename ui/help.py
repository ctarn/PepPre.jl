import tkinter as tk
from tkinter import ttk

import meta
import util

main = ttk.Frame()
main.pack(fill="both")

notebook = ttk.Notebook(main)
notebook.pack(fill="both")

F = ttk.Frame()
F.pack(fill="both")
util.add_text(F, meta.help_citation)
notebook.add(F, text="Citation")

F = ttk.Frame()
F.pack(fill="both")
util.add_text(F, meta.help_isolate)
notebook.add(F, text="Isolated Precursor")

F = ttk.Frame()
F.pack(fill="both")
util.add_text(F, meta.help_global)
notebook.add(F, text="Global Precursor")

F = ttk.Frame()
F.pack(fill="both")
util.add_text(F, meta.help_view)
notebook.add(F, text="Visualization")
