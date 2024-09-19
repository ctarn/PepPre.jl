width = ARGS[1]
path_data = ARGS[2]
path_out = ARGS[3]
runs = eval(Meta.parse(ARGS[4]))

unify_path(path) = replace(path, "/" => "\\")

rpath = "..\\.."

files = filter(f -> startswith(f, basename(path_data)) && endswith(f, ".raw"), readdir(dirname(path_data)))
println(dirname(path_data))
foreach(println, files)

cmds = String[]
for run in runs
    path_run = joinpath(path_out, "$(run)")
    cfg = """
[Basic Options]
datanum=$(length(files))
$(join(map(i -> "datapath$(i)=$(rpath)\\$(unify_path(path_run))\\$(files[i])", eachindex(files)), "\n"))

[Advanced Options]
co-elute=1
input_format=raw
isolation_width=$(width)
mars_threshold=$(run)
ipv_file=.\\IPV.txt
trainingset=.\\TrainingSet.txt

[Internal Switches]
output_mars_y=0
delete_msn=0
output_mgf=1
output_pf=0
debug_mode=0
check_activationcenter=1
output_all_mars_y=0
rewrite_files=0
export_unchecked_mono=0
cut_similiar_mono=1
mars_model=4
output_trainingdata=0

[About pXtract]
m/z=5
Intensity=1
"""
    mkpath(path_run)
    open(joinpath(path_run, "pParse2.cfg"), write=true) do io
        write(io, cfg)
    end
    path_run = "$(rpath)\\$(unify_path(path_run))"
    for file in files
        push!(cmds, "DEL $(path_run)\\$(splitext(file)[1]).csv\n")
        push!(cmds, "@echo > $(path_run)\\$(splitext(file)[1]).raw\n")
        push!(cmds, "@echo > $(path_run)\\$(splitext(file)[1]).xtract\n")
        push!(cmds, "mklink /h $(path_run)\\$(splitext(file)[1]).ms1 $(rpath)\\$(unify_path(dirname(path_data)))\\$(splitext(file)[1]).ms1\n")
        push!(cmds, "mklink /h $(path_run)\\$(splitext(file)[1]).ms2 $(rpath)\\$(unify_path(dirname(path_data)))\\$(splitext(file)[1]).ms2\n")
    end
    push!(cmds, "start /b pParse.exe $(path_run)\\pParse2.cfg\n")
end

open(joinpath(path_out, "pParse2.bat"), write=true) do io
    foreach(c -> write(io, c), cmds)
end
