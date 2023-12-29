import os
from pathlib import Path
import tkinter as tk

import util

name = "PepPre"
version = "1.3.0-dev"
author = "Tarn Yeong Ching"
url = f"http://{name.lower()}.ctarn.io"
server = f"http://api.ctarn.io/{name}/{version}"
copyright = f"{name} {version}\nCopyright © 2023 {author}\n{url}"
homedir = os.path.join(Path.home(), f".{name}", f"v{'.'.join(version.split('.')[0:2])}")
citation_bib = """@article{Tarn2023PepPre,
    author = {Ching Tarn and Yu-Zhuo Wu and Kai-Fei Wang},
    title = {PepPre: Promote Peptide Identification Using Accurate and Comprehensive Precursors},
    journal = {Journal of Proteome Research},
    doi = {10.1021/acs.jproteome.3c00293},
    url = {https://doi.org/10.1021/acs.jproteome.3c00293},
    year = {2023},
    type = {Journal Article}
}
"""
citation_apa = """Tarn, C., Wu, Y.-Z., & Wang, K.-F. (2023). PepPre: Promote Peptide Identification Using Accurate and Comprehensive Precursors. Journal of Proteome Research. https://doi.org/10.1021/acs.jproteome.3c00293"""

os.makedirs(homedir, exist_ok=True)

win = tk.Tk()
win.title(name)
win.iconphoto(True, tk.PhotoImage(file=util.get_content(f"{name}.png", shared=True)))
win.resizable(False, False)

if util.is_darwin:
    path_mono = "/Library/Frameworks/Mono.framework/Versions/Current/Commands/mono"
else:
    path_mono = "mono"

vars_spec = {
    "peppreisolated": {"type": tk.StringVar, "value": util.get_content("PepPre", "bin", "PepPreIsolated")},
    "peppreglobal": {"type": tk.StringVar, "value": util.get_content("PepPre", "bin", "PepPreGlobal")},
    "pepprealign": {"type": tk.StringVar, "value": util.get_content("PepPre", "bin", "PepPreAlign")},
    "peppreview": {"type": tk.StringVar, "value": util.get_content("PepPre", "bin", "PepPreView")},
    "thermorawread": {"type": tk.StringVar, "value": util.get_content("ThermoRawRead", "ThermoRawRead.exe", shared=True)},
    "monoruntime": {"type": tk.StringVar, "value": path_mono},
    "msconvert": {"type": tk.StringVar, "value": util.get_content("ProteoWizard", "msconvert")},
    "cfg": {"type": tk.StringVar, "value": ""},
}
vars = {k: v["type"](value=v["value"]) for k, v in vars_spec.items()}
