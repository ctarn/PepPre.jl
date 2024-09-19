include("util.jl")

conv_path(path; recursive=true) = begin
    if endswith(path, ".mgf")
        @info "MGF loading from " * path
        M = pFind.read_mgf(path)
        path = joinpath(dirname(path), "PW", basename(path))
        @info "MGF (PW) saving to " * path
        UniMZ.safe_save(path) do path
            open(path; write=true) do io
                id = 1
                @showprogress for ms in M, ion in ms.ions
                    UniMZ.write_mgf(io, UniMZ.fork(ms; ions=[UniMZ.Ion(ion.mz, ion.z)]), "$(splitext(basename(path))[1]).$(id).$(id).$(ion.z)")
                    id += 1
                end
            end
        end
    end
    if recursive && isdir(path) && !endswith(path, "PW")
        @info "Enter " * path
        for p in readdir(path; join=true)
            conv_path(p; recursive)
        end
    end
end

dir = joinpath(ROOT, "out")
conv_path(dir; recursive=true)
