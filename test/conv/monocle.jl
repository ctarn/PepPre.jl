import CSV
import DataFrames
import UniMZ
import ProgressMeter: @showprogress

path_data = ARGS[1]
path_out = ARGS[2]

mkpath(path_out)

for file in UniMZ.match_path(path_data, ".ms2")
    @info "MS2 loading from " * file
    M = UniMZ.read_ms2(file)
    I = Dict()
    D = CSV.File(splitext(file)[1] * ".csv") |> DataFrames.DataFrame
    DataFrames.transform!(D, "scan number" => :id, "precursor m/z" => :mz, "precursor charge" => :z)
    for row in eachrow(D)
        push!(get!(I, row.id, UniMZ.Ion[]), UniMZ.Ion(row.mz, row.z))
    end
    name = splitext(basename(file))[1]
    path = joinpath(path_out, name * ".mgf")
    @info "result saving to " * path
    io = open(path * "~", write=true)
    @showprogress for m in M
        for (idx, ion) in enumerate(I[m.id])
            UniMZ.write_mgf(io, UniMZ.fork(m; ions=[ion]), "$(name).$(m.id).$(m.id).$(ion.z).$(idx-1).dta")
        end
    end
    close(io)
    mv(path * "~", path; force=true)
    println("fold: ", size(D, 1) / length(M))
end
