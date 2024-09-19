linker = ARGS[1]
db = ARGS[2]
path_data = ARGS[3]
runs = eval(Meta.parse(ARGS[4]))

unify_path(path) = replace(path, "/" => "\\")

rpath = "..\\.."

path_task = dirname(dirname(path_data))

cmds = String[]
for run in runs
    path_run = joinpath(path_task, "$(run)")
    files = filter(f -> startswith(f, basename(path_data)) && endswith(f, ".mgf"), readdir(path_run))
    println(path_run)
    foreach(println, files)
    clv = (linker == "DSSO" || linker == "DSBU")
    cfg = """
[version]
version = 2.3.9
[score]
simple_score_type = ST_XLINK_OBM25
[flow]
flow_type = $(clv ? "FT_SteppedCleavage_PEP_INDEX" : "FT_ION_INDEX")
$(clv ? "query_peaks_number = 300\npreproc_type = PPT_XLINK_CLV" : "")
processor_num = 4
result_output_path = $(rpath)\\$(unify_path(path_run))\\pLink\\
[database]
db_name = $(db)
enzyme_name = Trypsin
max_miss_site = 3
min_pep_mass = 600
max_pep_mass = 6000
min_pep_len = 6
max_pep_len = 60
[modification]
fix_total = 1
fix_mod1 = Carbamidomethyl[C]
var_total = 1
var_mod1 = Oxidation[M]
[linker]
linker_total = 1
linker1 = $(linker)
[ions]
fragment_tol = 20
fragment_tol_type = ppm
peptide_tol = 20
peptide_tol_type = ppm
simple_instrument = $(clv ? "HCD-MS-CLV-COARSE" : "HCD-basic")
refined_instrument = $(clv ? "HCD-MS-CLV-FINE" : "HCD")
[filter]
filter_tol = 10
filter_tol_type = ppm
FDR = 0.01
FDR_estimate_strategy = EFT_SPECTRAL_LEVEL
fdr_separate_or_global = EFT_INTRA_INTER_SEPARATE_FDR
evalue = 0
[spectrum]
spec_type = mgf
spec_num = $(length(files))
$(join(map(i -> "spec_path$(i) = $(rpath)\\$(unify_path(path_run))\\$(files[i])", eachindex(files)), "\n"))
[quant]
quant = 1|None
search_n14n15 = 0
"""
    mkpath(joinpath(path_run, "pLink"))
    open(joinpath(path_run, "pLink.cfg"), write=true) do io
        write(io, cfg)
    end
    push!(cmds, "start /b searcher.exe $(rpath)\\$(unify_path(path_run))\\pLink.cfg\n")
end

open(joinpath(path_task, "pLink.bat"), write=true) do io
    foreach(c -> write(io, c), cmds)
end
