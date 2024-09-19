include("util.jl")

load_psm_pre(df) = begin
    P = Dict{Tuple{String, Int}, Vector{UniMZ.Ion}}()
    for r in eachrow(df)
        push!(get!(P, (r.file, r.scan), UniMZ.Ion[]), UniMZ.Ion(r.mz, r.z))
    end
    return P
end

load_mgf_pre(path) = begin
    P = Dict{Tuple{String, Int}, Vector{UniMZ.Ion}}()
    for path in UniMZ.match_path(path, ".mgf.csv")
        @info "Ion loading from " * path
        D = CSV.File(path) |> DataFrames.DataFrame
        file = splitext(splitext(basename(path))[1])[1]
        if endswith(file, "_HCDFT")
            file = file[begin:end-6]
        end
        for ion in eachrow(D)
            push!(get!(P, (file, ion.scan), UniMZ.Ion[]), UniMZ.Ion(ion.mz, ion.z))
        end
    end
    return P
end

diff(A, B) = begin
    map(collect(A)) do (k, v)
        map(v) do r
            !any(i -> UniMZ.in_moe(i.mz, r.mz, ε) && i.z == r.z, get(B, k, UniMZ.Ion[]))
        end |> sum
    end |> sum
end

draw!(fig, gs, row, col, la, lb, p_a, p_b) = begin
    a = sum(length, values(p_a))
    b = sum(length, values(p_b))
    a_b = diff(p_a, p_b)
    b_a = diff(p_b, p_a)
    ab = a - a_b
    ba = b - b_a
    @info "$(la) & $(lb): |A| - |A \\ B| = $(ab), |B| - |B \\ A| = $(ba)"
    return Plot.venn!(fig.add_subplot(gs[row, col]), a_b, b_a, ab, la, lb)
end

check_far(df, M, offset) = begin
    map(eachrow(df)) do r
        r.mz - M[r.file][r.scan].activation_center < -(M[r.file][r.scan].isolation_width / 2 + offset)
    end
end

filter_psm(df, ions) = begin
    map(eachrow(df)) do r
        !any(i -> UniMZ.in_moe(i.mz, r.mz, 20e-6) && i.z == r.z, get(ions, (r.file, r.scan), UniMZ.Ion[]))
    end
end
