import UniMZ
import ProgressMeter: @showprogress

path_data = ARGS[1]
path_out = ARGS[2]
offset = parse(Float64, ARGS[3])
zs = 2:6
ε = 20e-6

mkpath(path_out)

V = UniMZ.build_ipv()

for file in readdir(dirname(path_data))
    if startswith(file, basename(path_data)) && endswith(file, ".ms1")
        name = splitext(file)[1]

        path = joinpath(dirname(path_data), name * ".ms1")
        @info "MS1 loading from " * path
        M1 = UniMZ.read_ms1(path) |> UniMZ.index_by_id
        path = joinpath(dirname(path_data), name * ".ms2")
        @info "MS2 loading from " * path
        M2 = UniMZ.read_ms2(path)

        path = joinpath(path_out, "$(name).mgf")
        @info "result saving to " * path
        io = open(path * "~", write=true)

        n1 = 0
        n2 = 0
        @showprogress for m2 in M2
            m1 = M1[m2.pre]
            mz = m2.activation_center
            r = m2.isolation_width / 2
            peaks = UniMZ.query(m1.peaks, mz - r - offset, mz + r)
            ions = [UniMZ.Ion(p.mz, z) for p in peaks for z in zs]
            n1 += length(ions)
            ions = filter(i -> !isempty(UniMZ.query_ε(m1.peaks, UniMZ.ipv_mz(i, 2, V), ε)), ions)
            n2 += length(ions)
            for (idx, ion) in enumerate(ions)
                UniMZ.write_mgf(io, UniMZ.fork(m2; ions=[ion]), "$(name).$(m2.id).$(m2.id).$(ion.z).$(idx-1).dta")
            end
        end
        println("fold: $(n1 / length(M2)) -> $(n2 / length(M2))")
        close(io)
        mv(path * "~", path; force=true)
    end
end
