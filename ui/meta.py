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

help_citation = """Please cite the following work if you use the software in your work. 

BibTeX:
@article{Tarn2023PepPre,
    author = {Ching Tarn and Yu-Zhuo Wu and Kai-Fei Wang},
    title = {PepPre: Promote Peptide Identification Using Accurate and Comprehensive Precursors},
    journal = {Journal of Proteome Research},
    doi = {10.1021/acs.jproteome.3c00293},
    url = {https://doi.org/10.1021/acs.jproteome.3c00293},
    year = {2023},
    type = {Journal Article}
}

APA 7th:
Tarn, C., Wu, Y.-Z., & Wang, K.-F. (2023). PepPre: Promote Peptide Identification Using Accurate and Comprehensive Precursors. Journal of Proteome Research. https://doi.org/10.1021/acs.jproteome.3c00293

⧫ Free feel to contact me if you have any questions :).

Tarn Yeong Ching (i@ctarn.io)
"""

help_isolate = """Note:
⧫ For .ms2 files, corresponding .ms1 files should be in the same directory.
⧫ The `IPV` (isotopic pattern vectors) can be automatically generated and cached to specified path.
⧫ The `Isolation Width` can be set as `auto` if .raw files are provided or using .ms2 files containing `IsolationWidth` line.
⧫ Select multiple data files using something like `Ctrl + A`.
"""

help_global = """Note:
⧫ The `IPV` (isotopic pattern vectors) can be automatically generated and cached to specified path.
⧫ Select multiple data files using something like `Ctrl + A`.
"""

help_view = """Note:
⧫ A web page will be opened in the default browser automatically after clicking `Run Task`.
  Otherwise, you can open the web page manually by visiting above URL in your browser.
⧫ Most error messages can be safely ignored if the web page is updated as you clicking.
⧫ Please click `New Port` and re-run the task if you see the error message `address already in use`.
⧫ The `Output Directory` is only used to store saved task.
⧫ Please configure `pFind Directory` if you want to use customized pFind settings.
  The path should be `C:\\pFindStudio\\pFind3\\bin` by default on Windows.
"""
