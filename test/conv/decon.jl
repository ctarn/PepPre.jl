import CSV
import UniMZ
import ProgressMeter: @showprogress

dir_ms = ARGS[1]
dir_feat = ARGS[2]
dir_out = ARGS[3]
mkpath(dir_out)

for file in readdir(dir_feat)
    if endswith(file, "_isos.csv")
        path_feat = joinpath(dir_feat, file)
        @info "features loading from " * path_feat
        I = Dict{Int, Vector{UniMZ.Ion}}()
        @showprogress for i in CSV.File(path_feat; delim=',')
            push!(get!(I, i.scan_num, UniMZ.Ion[]), UniMZ.Ion(i.mz, i.charge))
        end
        name = file[begin:end-9]
        path_ms = joinpath(dir_ms, name * ".ms2")
        @info "MS2 loading from " * path_ms
        M2 = UniMZ.read_ms2(path_ms)
        path = joinpath(dir_out, name * ".mgf")
        @info "result saving to " * path
        io = open(path * "~", write=true)
        n = 0
        @showprogress for ms in M2
            ions = get!(I, ms.pre, UniMZ.Ion[])
            ions = filter(ions) do ion
                abs(ion.mz - ms.activation_center) <= ms.isolation_width / 2
            end
            n += length(ions)
            for (idx, ion) in enumerate(ions)
                UniMZ.write_mgf(io, UniMZ.fork(ms; ions=[ion]), "$(name).$(ms.id).$(ms.id).$(ion.z).$(idx-1).dta")
            end
        end
        close(io)
        mv(path * "~", path; force=true)
        println("fold: ", n / length(M2))
    end
end
