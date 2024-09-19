path_fasta = ARGS[1]
path_data = ARGS[2]
runs = eval(Meta.parse(ARGS[3]))

unify_path(path) = replace(path, "/" => "\\")

rpath = "..\\.."

path_task = dirname(dirname(path_data))

cmds = String[]
for run in runs
    path_run = joinpath(path_task, "$(run)")
    files = filter(f -> startswith(f, basename(path_data)) && endswith(f, ".mgf"), readdir(path_run))
    println(path_run)
    foreach(println, files)
    cfg = """
[Version]
pFind_Version=EVA.3.0.11

[param]
thread=4
activation_type=HCD-FTMS
mstol=20
mstolppm=1
msmstol=20
msmstolppm=1
temppepnum=100
pepnum=10
selectpeak=200
maxprolen=60000000
maxspec=100000
IeqL=1
npep=2
maxdelta=500
selectmod=
fixmod=
maxmod=3
enzyme=Trypsin KR _ C
digest=3
max_clv_sites=3

[filter]
psm_fdr=0.01
psm_fdr_type=0
mass_lower=600
mass_upper=10000
len_lower=6
len_upper=100
pep_per_pro=1
pro_fdr=0.01

[engine]
open=1
open_tag_len=5

rest_tag_iteration=1
rest_tag_len=4
rest_mod_num=10

salvo_iteration=1
salvo_mod_num=5

[file]
modpath=.\\modification.ini
fastapath=$(rpath)\\$(unify_path(path_fasta))
outputpath=$(rpath)\\$(unify_path(path_run))\\pFind\\
outputname=$(basename(path_task))_$(run)

[datalist]
msmsnum=$(length(files))
$(join(map(i -> "msmspath$(i)=$(rpath)\\$(unify_path(path_run))\\$(files[i])", eachindex(files)), "\n"))
msmstype=MGF

[quant]
quant=1|None

[system]
log=LOG_INFO
"""
    mkpath(joinpath(path_run, "pFind"))
    open(joinpath(path_run, "pFind.cfg"), write=true) do io
        write(io, cfg)
    end
    push!(cmds, "start /b Searcher.exe $(rpath)\\$(unify_path(path_run))\\pFind.cfg\n")
end

open(joinpath(path_task, "pFind.bat"), write=true) do io
    foreach(c -> write(io, c), cmds)
end
