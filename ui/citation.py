import tkinter as tk
from tkinter import ttk

import meta

main = ttk.Frame()
main.pack(fill="both")

ttk.Label(main, text=f"Please cite the following work if you use {meta.name} in your work.", justify="left").pack(fill="x", ipadx=4, ipady=16)

ttk.Label(main, text="BibTeX").pack()
bib = tk.Text(main, height=12)
bib.pack(fill="x")
bib.insert("end", meta.citation_bib)
bib.configure(state="disabled")

ttk.Label(main, text="APA 7th").pack()
apa = tk.Text(main, height=4)
apa.pack(fill="x")
apa.insert("end", meta.citation_apa)
apa.configure(state="disabled")
