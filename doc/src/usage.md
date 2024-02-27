# [Usage](@id usage)

## Download

Please download the software from [https://peppre.ctarn.io](https://peppre.ctarn.io).

## Install

### Linux or Windows

Please unzip the downloaded `.zip` file, and PepPre can be used directly without installation.

### macOS

For macOS users, we provide both `.pkg` and `.zip` files.

We would recommend to use the `.pkg` file which can be installed by simply double clicking it.
The software would be installed at `/Applications/PepPre.app` by default.

The `.zip` file contains the `.app` package software and can be used directly without installation.
If the macOS says:

```
“PepPre.app” is damaged and can’t be opened. You should move it to the Trash.
```

Please run 
```sh
sudo xattr -r -d com.apple.quarantine [path/to/PepPre.app]
```
in terminal to remove the quarantine attributions.

## Run

The software provides a graphic user interface (GUI) and a command line interface (CLI).
You can run the GUI by double clicking the icon of the software.
For Linux and Windows users, you can find the executable files in `content` folder under the unzipped folder.

You can run the executable files with `--help` to see the usage of the CLI:
```
usage: PepPre [-o output] [--ipv IPV] [--mode mono|max] [-w Th]
              [-z min:max] [-e ppm] [-t (≥0.0)] [-n fold] [--inst]
              [-f csv,tsv,ms2,mgf] [-h] data...

positional arguments:
  data                  list of .mes or .ms1/2 files; .ms2/1 files
                        should be in the same directory for .ms1/2

optional arguments:
  -o, --out output      output directory (default: "./out/")
  --ipv IPV             Isotope Pattern Vector file (default:
                        "/Users/i/.UniMS/peptide.ipv")
  --mode mono|max       by mono or max mode (default: "mono")
  -w, --width Th        isolation width (default: "auto")
  -z, --charge min:max  charge states (default: "2:6")
  -e, --error ppm       m/z error (default: "10.0")
  -t, --thres (≥0.0)    exclusion threshold (default: "1.0")
  -n, --fold fold       number of precursor ions (default: "4.0")
  --inst                preserve original (instrument) ions
  -f, --fmt csv,tsv,ms2,mgf
                        output format (default: "csv")
  -h, --help            show this help message and exit
```

For macOS users, the executable files would be located at `/Applications/PepPre.app/Contents/MacOS/content/` by default.

## Parameters

- It is recommended to set the mass error to 10 ppm. And for MS1 scans with resolution ≤ 30k, error < 10 ppm may cause performance loss.
- The `IPV` would be generated automatically based on the Averagine model.

## Input and Output

The software accepts `.mes`, `.ms1/.ms2`, and `.raw` files as input.
For data in other formats, you can convert them into `.mes` and `.ms1/.ms2` files.

The software outputs `.csv`, `.tsv`, `.ms2`, and `.mgf` files.
The `.csv` and `.tsv` files are list of precursor ions without MS/MS spectrum peaks.
The `.ms2` and `.mgf` files contain both the precursors ions and MS/MS spectrum peaks, and can be used for peptide identification directly.
