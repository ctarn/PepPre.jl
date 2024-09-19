import UniMZ
import ProgressMeter: @showprogress

path_data = ARGS[1]
path_out = ARGS[2]

dir_apl = joinpath(dirname(path_data), "combined", "andromeda")
I = Dict()
for file in readdir(dir_apl)
    if startswith(file, "allSpectra.HCD.FTMS.iso_") && endswith(file, ".apl")
        mz = z = name = id = nothing
        io = open(joinpath(dir_apl, file))
        @info "ions loading from " * file
        while !eof(io)
            line = readline(io)
            if length(line) == 0
                continue
            elseif line == "peaklist start"
                mz = z = name = id = nothing
            elseif line == "peaklist end"
                push!(get!(get!(I, name, Dict()), id, UniMZ.Ion[]), UniMZ.Ion(mz, z))
            elseif startswith(line, "mz=")
                mz = parse(Float64, line[4:end])
            elseif startswith(line, "charge=")
                z = parse(Int, line[8:end])
            elseif startswith(line, "header=")
                items = split(line[8:end])
                name = items[2]
                id = parse(Int, items[4])
            end
        end
    end
end

for file in readdir(dirname(path_data))
    if startswith(file, basename(path_data)) && endswith(file, ".ms2")
        fname = joinpath(dirname(path_data), file)
        @info "MS2 loading from " * fname
        M2 = UniMZ.read_ms2(fname)
        mkpath(path_out)
        path = joinpath(path_out, splitext(basename(fname))[1] * ".mgf")
        name = splitext(basename(fname))[1]
        @info "result saving to " * path
        io = open(path * "~", write=true)
        @showprogress for ms in M2
            for (idx, ion) in enumerate(I[name][ms.id])
                UniMZ.write_mgf(io, UniMZ.fork(ms; ions=[UniMZ.Ion(ion.mz, ion.z)]), "$(name).$(ms.id).$(ms.id).$(ion.z).$(idx-1).dta")
            end
        end
        close(io)
        mv(path * "~", path; force=true)
    end
end
