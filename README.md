# PepPre.jl
PepPre is a method to detect peptide precursors from LC-MS map to promote peptide identification, validation, etc.

## For User
Please visit [https://peppre.ctarn.io](https://peppre.ctarn.io) for access to software or documents.

Please contact [i@ctarn.io](mailto:i@ctarn.io) if you have any problems.

## For Developer
### Install Julia

Please install Julia (version 1.9 or newer) from [https://julialang.org](https://julialang.org).

### Clone the Repos
Please clone [MesMS.jl](https://github.com/MesMS/MesMS.jl) and [PepPre.jl](https://github.com/ctarn/PepPre.jl) by:
```sh
git clone git@github.com:MesMS/MesMS.jl.git
git clone git@github.com:ctarn/PepPre.jl.git
```

### Compile the Project
Please `cd` to the root folder of `PepPre.jl`:
```sh
cd PepPre.jl
```

And the compile the project using:
```sh
julia --project=. util/complie.jl
```

The complied files would be located at `./tmp/{your platform}/`.

### Build GUI and Installer
Finally, please run the scripts based on your platform if you want to build the graphic user inerface and package the software:
```sh
sh util/build_linux.sh
# or 
sh util/build_macos.sh
# or
./util/build_windows.bat
```

Python, PyInstaller, and Tkinter are required to build the GUI.
You can also call PepPre or PepPreView from command line directly using the compiled files.

The packaged software would be located at `./tmp/release/`.

## Citation

### BibTeX

```BibTeX
@article{Tarn2024PepPre,
    author = {Ching Tarn and Yu-Zhuo Wu and Kai-Fei Wang},
    title = {PepPre: Promote Peptide Identification Using Accurate and Comprehensive Precursors},
    journal = {Journal of Proteome Research},
    doi = {10.1021/acs.jproteome.3c00293},
    url = {https://doi.org/10.1021/acs.jproteome.3c00293},
    year = {2024},
    type = {Journal Article}
}
```

### APA

```
Tarn, C., Wu, Y.-Z., & Wang, K.-F. (2024). PepPre: Promote Peptide Identification Using Accurate and Comprehensive Precursors. Journal of Proteome Research. https://doi.org/10.1021/acs.jproteome.3c00293
```
