using Statistics

import CSV
import UniMZ
import ProgressMeter: @showprogress

dir_ms = ARGS[1]
dir_feature = ARGS[2]
window = parse(Float64, ARGS[3])

for file in readdir(dir_feature)
    if endswith(file, ".features.tsv")
        name = file[begin:end-13]
        path_feature = joinpath(dir_feature, file)
        @info "features loading from " * path_feature
        csv = CSV.File(path_feature; delim='\t')
        path_ms = joinpath(dir_ms, name * ".ms2")
        @info "MS2 loading from " * path_ms
        M2 = UniMZ.read_ms2(path_ms)
        path = joinpath(dir_feature, name * ".mgf")
        @info "result saving to " * path
        io = open(path * "~", write=true)
        rts = map(ms -> ms.retention_time, M2)
        I = map(_ -> UniMZ.Ion[], M2)
        foreach(csv) do row
            mz = row.mz
            z = row.charge
            rt_start = row.rtStart * 60
            rt_stop = row.rtEnd * 60
            for i in searchsortedfirst(rts, rt_start):searchsortedlast(rts, rt_stop)
                if abs(M2[i].activation_center - mz) <= window / 2
                    push!(I[i], UniMZ.Ion(mz, z))
                end
            end
        end
        @showprogress for (ms, ions) in zip(M2, I)
            for (idx, ion) in enumerate(ions)
                UniMZ.write_mgf(io, UniMZ.fork(ms; ions=[ion]), "$(name).$(ms.id).$(ms.id).$(ion.z).$(idx-1).dta")
            end
        end
        close(io)
        mv(path * "~", path; force=true)
        println("fold: ", mean(length, I))
    end
end
