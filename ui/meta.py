import os
from pathlib import Path

name = "PepPre"
version = "1.0.2"
author = "Tarn Yeong Ching"
url = f"http://{name.lower()}.ctarn.io"
server = f"http://api.ctarn.io/{name}/{version}"
copyright = f"{name} {version}\nCopyright © 2023 {author}\n{url}"
homedir = os.path.join(Path.home(), f".{name}", version)
