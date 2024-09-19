import UniMZ
import ProgressMeter: @showprogress

path_data = ARGS[1]
path_out = ARGS[2]
runs = eval(Meta.parse(ARGS[3]))
Δ = 1.00335

subdir = !(typeof(runs) <: Number)
runs = subdir ? runs : [runs]

for file in readdir(dirname(path_data))
    if startswith(file, basename(path_data)) && endswith(file, ".ms2")
        fname = joinpath(dirname(path_data), file)
        @info "MS2 loading from " * fname
        M2 = UniMZ.read_ms2(fname)
        for n in runs
            path = subdir ? joinpath(path_out, string(n)) : path_out
            mkpath(path)
            path = joinpath(path, splitext(basename(fname))[1] * ".mgf")
            name = splitext(basename(fname))[1]
            @info "result saving to " * path
            io = open(path * "~", write=true)
            @showprogress for ms in M2
                ions = map(ms.ions) do ion
                    if ion.z > 0
                        return [UniMZ.Ion(ion.mz - Δ * i / ion.z, ion.z) for i in 0:(n-1)]
                    else
                        @warn "scan $(ms.id) has illegel ion: $(ion)"
                        return []
                    end
                end
                for (idx, ion) in enumerate(vcat(ions...))
                    UniMZ.write_mgf(io, UniMZ.fork(ms; ions=[UniMZ.Ion(ion.mz, ion.z)]), "$(name).$(ms.id).$(ms.id).$(ion.z).$(idx-1).dta")
                end
            end
            close(io)
            mv(path * "~", path; force=true)
        end
    end
end
