# [Development](@id dev)

## Install Julia

Please install Julia (version 1.9 or newer) from [https://julialang.org](https://julialang.org).

## Clone the Repos

Please clone [UniMS.jl](https://github.com/UniMSHub/UniMS.jl) and [PepPre.jl](https://github.com/ctarn/PepPre.jl) by:
```sh
git clone git@github.com:UniMSHub/UniMS.jl.git
git clone git@github.com:ctarn/PepPre.jl.git
```
or
```sh
git clone https://github.com/UniMSHub/UniMS.jl.git
git clone https://github.com/ctarn/PepPre.jl.git
```

## Compile the Project

Please `cd` to the root folder of `PepPre.jl`:
```sh
cd PepPre.jl
```

And the compile the project using:
```sh
julia --project=. util/complie.jl
```

The complied files would be located at `./tmp/{your platform}/`.

## Build GUI and Installer

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
