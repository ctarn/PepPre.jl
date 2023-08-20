var documenterSearchIndex = {"docs":
[{"location":"dev/#dev","page":"Development","title":"Development","text":"","category":"section"},{"location":"dev/#Install-Julia","page":"Development","title":"Install Julia","text":"","category":"section"},{"location":"dev/","page":"Development","title":"Development","text":"Please install Julia (version 1.9 or newer) from https://julialang.org.","category":"page"},{"location":"dev/#Clone-the-Repos","page":"Development","title":"Clone the Repos","text":"","category":"section"},{"location":"dev/","page":"Development","title":"Development","text":"Please clone MesMS.jl and PepPre.jl by:","category":"page"},{"location":"dev/","page":"Development","title":"Development","text":"git clone git@github.com:ctarn/MesMS.jl.git\ngit clone git@github.com:ctarn/PepPre.jl.git","category":"page"},{"location":"dev/","page":"Development","title":"Development","text":"or","category":"page"},{"location":"dev/","page":"Development","title":"Development","text":"git clone https://github.com/ctarn/MesMS.jl.git\ngit clone https://github.com/ctarn/PepPre.jl.git","category":"page"},{"location":"dev/#Compile-the-Project","page":"Development","title":"Compile the Project","text":"","category":"section"},{"location":"dev/","page":"Development","title":"Development","text":"Please cd to the root folder of PepPre.jl:","category":"page"},{"location":"dev/","page":"Development","title":"Development","text":"cd PepPre.jl","category":"page"},{"location":"dev/","page":"Development","title":"Development","text":"And the compile the project using:","category":"page"},{"location":"dev/","page":"Development","title":"Development","text":"julia --project=. util/complie.jl","category":"page"},{"location":"dev/","page":"Development","title":"Development","text":"The complied files would be located at ./tmp/{your platform}/.","category":"page"},{"location":"dev/#Build-GUI-and-Installer","page":"Development","title":"Build GUI and Installer","text":"","category":"section"},{"location":"dev/","page":"Development","title":"Development","text":"Finally, please run the scripts based on your platform if you want to build the graphic user inerface and package the software:","category":"page"},{"location":"dev/","page":"Development","title":"Development","text":"sh util/build_linux.sh\n# or \nsh util/build_macos.sh\n# or\n./util/build_windows.bat","category":"page"},{"location":"dev/","page":"Development","title":"Development","text":"Python, PyInstaller, and Tkinter are required to build the GUI. You can also call PepPre or PepPreView from command line directly using the compiled files.","category":"page"},{"location":"dev/","page":"Development","title":"Development","text":"The packaged software would be located at ./tmp/release/.","category":"page"},{"location":"#PepPre","page":"PepPre","title":"PepPre","text":"","category":"section"},{"location":"","page":"PepPre","title":"PepPre","text":"PepPre is a method to detect peptide precursors from LC-MS map to promote peptide identification, validation, etc.","category":"page"},{"location":"","page":"PepPre","title":"PepPre","text":"Please please download the releases from https://peppre.ctarn.io.","category":"page"},{"location":"","page":"PepPre","title":"PepPre","text":"Feel free to contact i@ctarn.io if you have any problems.","category":"page"},{"location":"#Citation","page":"PepPre","title":"Citation","text":"","category":"section"},{"location":"#BibTeX","page":"PepPre","title":"BibTeX","text":"","category":"section"},{"location":"","page":"PepPre","title":"PepPre","text":"@article{Tarn2023PepPre,\n    author = {Ching Tarn and Yu-Zhuo Wu and Kai-Fei Wang},\n    title = {PepPre: Promote Peptide Identification Using Accurate and Comprehensive Precursors},\n    year = {2023},\n    doi = {10.1101/2023.05.13.540645},\n    publisher = {Cold Spring Harbor Laboratory},\n    URL = {https://www.biorxiv.org/content/early/2023/05/14/2023.05.13.540645},\n    eprint = {https://www.biorxiv.org/content/early/2023/05/14/2023.05.13.540645.full.pdf},\n    journal = {bioRxiv}\n}","category":"page"},{"location":"#APA","page":"PepPre","title":"APA","text":"","category":"section"},{"location":"","page":"PepPre","title":"PepPre","text":"Tarn, C., Wu, Y.-Z., & Wang, K.-F. (2023). PepPre: Promote Peptide Identification Using Accurate and Comprehensive Precursors. bioRxiv, 2023.2005.2013.540645. https://doi.org/10.1101/2023.05.13.540645","category":"page"},{"location":"faq/#faq","page":"Frequently Asked Questions","title":"Frequently Asked Questions","text":"","category":"section"},{"location":"faq/#macOS-says:-“PepPre.app”-is-damaged-and-can’t-be-opened.-You-should-move-it-to-the-Trash.","page":"Frequently Asked Questions","title":"macOS says: “PepPre.app” is damaged and can’t be opened. You should move it to the Trash.","text":"","category":"section"},{"location":"faq/","page":"Frequently Asked Questions","title":"Frequently Asked Questions","text":"Please run sudo xattr -r -d com.apple.quarantine [path/to/PepPre.app] in terminal.","category":"page"},{"location":"faq/#Windows-Security-stops-the-software-and-deletes-the-.exe-file.","page":"Frequently Asked Questions","title":"Windows Security stops the software and deletes the .exe file.","text":"","category":"section"},{"location":"faq/","page":"Frequently Asked Questions","title":"Frequently Asked Questions","text":"The software is packaged using PyInstaller, and can be detected as virus by mistake on Windows (see the issue). Please restore the deleted file from Protection History, and Windows Security should not stop or delete it again. Otherwise, please add the software to white list. You can also package the software from source yourself.","category":"page"}]
}
