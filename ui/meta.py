import os
from pathlib import Path

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
    year = {2023},
    doi = {10.1101/2023.05.13.540645},
    publisher = {Cold Spring Harbor Laboratory},
    URL = {https://www.biorxiv.org/content/early/2023/05/14/2023.05.13.540645},
    eprint = {https://www.biorxiv.org/content/early/2023/05/14/2023.05.13.540645.full.pdf},
    journal = {bioRxiv}
}
"""
citation_apa = """Tarn, C., Wu, Y.-Z., & Wang, K.-F. (2023). PepPre: Promote Peptide Identification Using Accurate and Comprehensive Precursors. bioRxiv, 2023.2005.2013.540645. https://doi.org/10.1101/2023.05.13.540645"""
