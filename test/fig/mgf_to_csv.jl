include("util.jl")

conv_path(path; recursive=true) = begin
    if endswith(path, ".mgf")
        @info "MGF loading from " * path
        M = pFind.read_mgf(path)
        path_csv = path * ".csv"
        @info "CSV saving to " * path_csv
        open(path_csv * "~"; write=true) do io
            write(io, "scan,mz,z\n")
            for m in M, i in m.ions
                write(io, "$(m.id),$(i.mz),$(i.z)\n")
            end
        end
        mv(path_csv * "~", path_csv; force=true)
        if isfile(path_csv)
            @info "MGF removing from " * path
            rm(path)
        end
    end
    if recursive && isdir(path) && basename(path) != "PW"
        @info "Enter " * path
        for p in readdir(path; join=true)
            conv_path(p; recursive)
        end
    end
end

dir = joinpath(ROOT, "out")
conv_path(dir; recursive=true)
