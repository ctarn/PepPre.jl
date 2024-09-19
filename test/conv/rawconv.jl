import UniMZ
import ProgressMeter: @showprogress

path_data = ARGS[1]
path_out = ARGS[2]

for file in readdir(dirname(path_out))
    if !(startswith(file, basename(path_out)) && endswith(file, ".ms2"))
        continue
    end
    I = Dict()
    mz = z = id = nothing
    io = open(joinpath(path_out, file))
    @info "ions loading from " * file
    while !eof(io)
        line = readline(io)
        if startswith(line, "S\t")
            id = parse(Int, split(line)[2])
        elseif startswith(line, "Z\t")
            items = split(line)
            mh, z = parse(Float64, items[3]), parse(Int, items[2])
            mz = UniMZ.mh_to_mz(mh, z)
            push!(get!(I, id, UniMZ.Ion[]), UniMZ.Ion(mz, z))
        end
    end

    fname = joinpath(dirname(path_data), file)
    @info "MS2 loading from " * fname
    M2 = UniMZ.read_ms2(fname)
    path = joinpath(path_out, splitext(basename(fname))[1] * ".mgf")
    name = splitext(basename(fname))[1]
    @info "result saving to " * path
    io = open(path * "~", write=true)
    @showprogress for ms in M2
        for (idx, ion) in enumerate(I[ms.id])
            UniMZ.write_mgf(io, UniMZ.fork(ms; ions=[UniMZ.Ion(ion.mz, ion.z)]), "$(name).$(ms.id).$(ms.id).$(ion.z).$(idx-1).dta")
        end
    end
    close(io)
    mv(path * "~", path; force=true)
end
