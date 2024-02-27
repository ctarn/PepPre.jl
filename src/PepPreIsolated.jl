module PepPreIsolated

using Printf

import ArgParse
import ProgressMeter: @showprogress
import UniMS: UniMS, PepIso

merge_ions(ions, ε) = begin
    ans = empty(ions)
    length(ions) == 0 && return ans
    ions = sort(ions, by=i -> i.mz)
    sort!(ions, by=i -> i.z, alg=InsertionSort)
    mz, z, score = ions[begin].mz, ions[begin].z, ions[begin].score
    for i in ions[begin+1:end]
        if UniMS.in_moe(i.mz, mz, ε) && i.z == z
            mz = (mz * score + i.mz * i.score) / (score + i.score)
            score += i.score
        else
            push!(ans, (; mz, z, score))
            mz, z, score = i.mz, i.z, i.score
        end
    end
    push!(ans, (; mz, z, score))
    return ans
end

report_ions(Î, I, ε) = begin
    n̂, n = sum.(length, [Î, I])
    fs = Dict{Int, Int}()
    zs = Dict{Int, Int}()
    ms = Dict{Int, Int}()
    kept = 0
    for (îons, ions) in zip(Î, I)
        fs[length(îons)] = get(fs, length(îons), 0) + 1
        kept += sum(map(î -> any(i -> i.z == î.z && UniMS.in_moe(i.mz, î.mz, ε), ions), îons))
        for ion in îons
            zs[ion.z] = get(zs, ion.z, 0) + 1
            m = floor(Int, ion.mz * ion.z / 1000)
            ms[m] = get(ms, m, 0) + 1
        end
    end
    println.(['-'^16, "#ion\t#MS2", '-'^16])
    foreach(k -> println("$(k)\t$(get(fs, k, 0))"), range(extrema(keys(fs))...))
    println.(['-'^16, "charge\t#ion", '-'^16])
    foreach(k -> println("$(k)+\t$(get(zs, k, 0))"), range(extrema(keys(zs))...))
    println.(['-'^16, "mass\t#ion", '-'^16])
    foreach(k -> println("$(k)k Da\t$(get(ms, k, 0))"), range(extrema(keys(ms))...))
    println('-'^16)
    @printf("#ion: %d -> %d (%.2f× -> %.2f×)\n", n, n̂, n / length(I), n̂ / length(I))
    @printf("kept: %d / %d = %.2f%%\n", kept, length(I), kept / length(I) * 100)
end

slice_ms1(M1, M2, r=NaN) = begin
    i = 1
    M1 = map(M2) do m2
        r_ = isnan(r) ? m2.isolation_width / 2 : r
        while M1[i].id <= m2.id i += 1 end
        return map(m -> UniMS.query(m.peaks, m2.activation_center - r_ - 2, m2.activation_center + r_ + 4), M1[i-8:i+7])
    end
    return M1
end

evaluate(ms1, mz, r, zs, ε, V, τ, mode) = begin
    δs = mode == :mono ? zeros(length(zs)) : map(zs) do z
        UniMS.ipv_dmz(mz, z, argmax(UniMS.ipv_w(mz, z, V)), V)
    end
    ions = map(ms1) do spec
        peaks = UniMS.query(spec, mz - r - 2, mz + r + 1)
        ions = [UniMS.Ion(p.mz - δ, z) for p in peaks for (z, δ) in zip(zs, δs)]
        ions = filter(i -> i.mz * i.z < UniMS.ipv_max(V) && PepIso.prefilter(i, spec, ε, V, mode), ions)
        ions = PepIso.deisotope(ions, spec, τ, ε, V)
        inten = sum(p -> p.inten, UniMS.query(peaks, mz - r, mz + r); init=1.0e-16)
        ions = map(ions) do ion
            ratio = sum(UniMS.ipv_w(ion, V)[UniMS.argquery_δ(UniMS.ipv_mz(ion, V), mz, r)]; init=0.0)
            return (; mz=ion.mz::Float64, z=ion.z::Int, score=(ion.m * ion.x * ratio / inten)::Float64)
        end
        return filter(i -> i.score > 0, ions)
    end
    return length(ions) == 1 ? ions[begin] : [(; i..., score=i.score / length(ms1)) for i in merge_ions(vcat(ions...), ε)]
end

filter_by_fold(I, fold) = begin
    scores = map(i -> i.score, reduce(vcat, I))
    n = min(length(scores), round(Int, (length(I) * fold)))
    τ = partialsort!(scores, n; rev=true)
    I = @showprogress map(I) do ions
        return filter(i -> i.score >= τ, ions)
    end
    return I
end

tune_mass(ion, ms1s, ε) = begin
    peaks = map(ms1s) do spec
        r = UniMS.argquery_ε(spec, ion.mz, ε)
        return isempty(r) ? UniMS.Peak(0.0, 0.0) : UniMS.query_near(spec[r], (; ion.mz); by=x -> x.mz)
    end
    mz = sum(p -> p.mz * p.inten, peaks) / sum(p -> p.inten, peaks)
    return isnan(mz) ? ion : (; ion..., mz)
end

prepare(args) = begin
    out = mkpath(args["out"])
    V = UniMS.build_ipv(args["ipv"])
    mode = Symbol(args["mode"])
    if mode ∉ [:mono, :max]
        @warn "unknown mode, replaced with `mono`: $(mode)"
        mode = :mono
    end
    r = args["width"] == "auto" ? NaN : parse(Float64, args["width"]) / 2
    zs = Vector{Int}(UniMS.parse_range(Int, args["charge"]))
    ε = parse(Float64, args["error"]) * 1.0e-6
    τ = parse(Float64, args["thres"])
    folds = Vector{Float64}(UniMS.parse_range(Float64, args["fold"]))
    inst = args["inst"]::Bool
    fmts = split(args["fmt"], ",") .|> strip .|> Symbol
    subdir = ':' ∈ args["fold"]
    batchsize = parse(Int, args["split"])
    return (; out, V, mode, r, zs, ε, τ, folds, inst, fmts, subdir, batchsize)
end

process(path; out, V, mode, r, zs, ε, τ, folds, inst, fmts, subdir, batchsize) = begin
    M = UniMS.read_ms(path)
    M1, M2 = M.MS1, M.MS2
    prepend!(M1, [UniMS.MS1(id=typemin(Int)) for i in 1:8])
    append!(M1, [UniMS.MS1(id=typemax(Int)) for i in 1:8])
    @info "MS1 slicing"
    M1 = slice_ms1(M1, M2, r)

    @info "evaluating"
    I = @showprogress map(M1, M2) do ms1, ms2
        r_ = isnan(r) ? ms2.isolation_width / 2 : r
        ions = evaluate(ms1[8:9], ms2.activation_center, r_, zs, ε, V, τ, mode)
        if inst
            ions = filter(i -> !any(x -> i.z == x.z && UniMS.in_moe(i.mz, x.mz, ε), ms2.ions), ions)
            append!(ions, [(; i.mz, i.z, score=Inf) for i in ms2.ions])
        end
        return sort(ions; by=i -> i.score, rev=true)
    end
    for fold in folds
        @info "filtering by $(fold)-fold"
        I_ = filter_by_fold(I, fold)

        @info "fine-tuning"
        I_ = @showprogress map(I_, M1) do ions, ms1
            map(ion -> tune_mass(ion, ms1, ε / 2), ions)
        end

        report_ions(I_, map(m -> m.ions, M2), ε)
        name = basename(splitext(path)[1])
        for fmt in fmts
            ext = fmt ∈ [:csv, :tsv] ? "precursor.$(fmt)" : fmt
            if batchsize ≤ 0
                p = joinpath(subdir ? joinpath(out, "$(fold)") : out, "$(name).$(ext)")
                UniMS.safe_save(p -> UniMS.write_ms_with_precursor(p, M2, I_; fmt, name), p)
            else
                nbatch = length(M2)÷batchsize
                for i in 1:nbatch
                    r = (i * batchsize):min(length(M2), (i + 1) * batchsize)
                    p = joinpath(subdir ? joinpath(out, "$(fold)") : out, "$(name).$(nbatch)_$(i).$(ext)")
                    UniMS.safe_save(p -> UniMS.write_ms_with_precursor(p, M2[r], I_[r]; fmt, name), p)
                end
            end
        end
    end
end

main() = begin
    settings = ArgParse.ArgParseSettings(prog="PepPreIsolated")
    ArgParse.@add_arg_table! settings begin
        "data"
            help = "list of .mes or .ms1/2 files; .ms2/1 files should be in the same directory for .ms1/2"
            nargs = '+'
            required = true
        "--out", "-o"
            help = "output directory"
            metavar = "output"
            default = "./out/"
        "--ipv"
            help = "Isotope Pattern Vector file"
            metavar = "IPV"
            default = joinpath(homedir(), ".UniMS/peptide.ipv")
        "--mode"
            help = "by mono or max mode"
            metavar = "mono|max"
            default = "mono"
        "--width", "-w"
            help = "isolation width"
            metavar = "Th"
            default = "auto"
        "--charge", "-z"
            help = "charge states"
            metavar = "min:max"
            default = "2:6"
        "--error", "-e"
            help = "m/z error"
            metavar = "ppm"
            default = "10.0"
        "--thres", "-t"
            help = "exclusion threshold"
            metavar = "(≥0.0)"
            default = "1.0"
        "--fold", "-n"
            help = "number of precursor ions"
            metavar = "fold"
            default = "4.0"
        "--split"
            help = "split into sub-files"
            metavar = "n"
            default = "0"
        "--inst"
            help = "preserve original (instrument) ions"
            action = :store_true
        "--fmt", "-f"
            help = "output format"
            metavar = "csv,tsv,ms2,mgf,pf2"
            default = "csv"
    end
    args = ArgParse.parse_args(settings)
    paths = reduce(vcat, UniMS.match_path.(args["data"], ".mes")) |> unique |> sort
    @info "file paths of selected data:"
    foreach(x -> println("$(x[1]):\t$(x[2])"), enumerate(paths))
    process.(paths; prepare(args)...)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

julia_main()::Cint = begin
    main()
    return 0
end

end
