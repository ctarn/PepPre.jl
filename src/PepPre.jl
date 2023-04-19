module PepPre

using Base: Filesystem
using Printf

import ArgParse
import MesMS
import MesMS: PepIso
import ProgressMeter: @showprogress

merge_ions(ions, ε) = begin
    ans = empty(ions)
    length(ions) == 0 && return ans
    ions = sort(ions, by=i -> i.mz)
    sort!(ions, by=i -> i.z, alg=InsertionSort)
    mz, z, score = ions[begin].mz, ions[begin].z, ions[begin].score
    for i in ions[begin+1:end]
        if MesMS.in_moe(i.mz, mz, ε) && i.z == z
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
        kept += sum(map(î -> any(i -> i.z == î.z && MesMS.in_moe(i.mz, î.mz, ε), ions), îons))
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
        return map(m -> MesMS.query(m.peaks, m2.activation_center - r_ - 2, m2.activation_center + r_ + 4), M1[i-8:i+7])
    end
    return M1
end

evaluate(ms1, mz, r, zs, ε, V, τ, mode) = begin
    δs = map(zs) do z
        if mode == :mono return 0.0 end
        # else max mode
        m = mz * z
        i = argmax(MesMS.ipv_w(m, V))
        return (MesMS.ipv_m(m, V)[i] - MesMS.ipv_m(m, V)[1]) / z
    end
    ions = map(ms1) do spec
        peaks = MesMS.query(spec, mz - r - 2, mz + r + 1)
        ions = [MesMS.Ion(p.mz - δ, z) for p in peaks for (z, δ) in zip(zs, δs)]
        ions = filter(i -> i.m < length(V) && PepIso.prefilter(i, spec, ε, V, mode), ions)
        ions = PepIso.deisotope(ions, spec, τ, ε, V)
        inten = sum(p -> p.inten, MesMS.query(peaks, mz - r, mz + r), init=1.0e-16)
        ions = map(ions) do ion
            ratio = sum(MesMS.ipv_w(ion, V)[MesMS.argquery_δ(MesMS.ipv_mz(ion, V), mz, r)], init=0.0)
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
        r = MesMS.argquery_ε(spec, ion.mz, ε)
        return isempty(r) ? MesMS.Peak(0.0, 0.0) : MesMS.query_near(spec[r], ion.mz; by=x -> x.mz)
    end
    mz = sum(p -> p.mz * p.inten, peaks) / sum(p -> p.inten, peaks)
    return isnan(mz) ? ion : (; ion..., mz)
end

write_ions(fmt, io, M, I; name="filename") = begin
    if fmt == "csv"
        write(io, "scan,mz,z\n")
        @showprogress for (ms, ions) in zip(M, I)
            foreach(ion -> write(io, "$(ms.id),$(ion.mz),$(ion.z)\n"), ions)
        end
    elseif fmt == "tsv"
        write(io, "scan\tmz\tz\n")
        @showprogress for (ms, ions) in zip(M, I)
            foreach(ion -> write(io, "$(ms.id)\t$(ion.mz)\t$(ion.z)\n"), ions)
        end
    elseif fmt == "ms2"
        @showprogress for (ms, ions) in zip(M, I)
            MesMS.write_ms2(io, MesMS.fork(ms; ions=[MesMS.Ion(ion.mz, ion.z) for ion in ions]))
        end
    elseif fmt == "mgf"
        @showprogress for (ms, ions) in zip(M, I)
            for (idx, ion) in enumerate(ions)
                MesMS.write_mgf(io, MesMS.fork(ms; ions=[MesMS.Ion(ion.mz, ion.z)]), "$(name).$(ms.id).$(ms.id).$(ion.z).$(idx-1).dta")
            end
        end
    end
end

prepare(args) = begin
    inst = args["inst"]::Bool
    mode = Symbol(args["mode"])
    if mode ∉ [:mono, :max]
        @warn "unknown mode, replaced with `mono`: $(mode)"
        mode = :mono
    end
    V = MesMS.build_ipv(args["ipv"])
    r = args["width"] == "auto" ? NaN : parse(Float64, args["width"]) / 2
    zs = Vector{Int}(MesMS.parse_range(Int, args["charge"]))
    ε = parse(Float64, args["error"]) * 1.0e-6
    τ = parse(Float64, args["thres"])
    folds = Vector{Float64}(MesMS.parse_range(Float64, args["fold"]))
    fmts = split(args["fmt"], ",")
    subdir = ':' ∈ args["fold"]
    out = args["out"]
    return (; inst, mode, V, r, zs, ε, τ, folds, fmts, subdir, out)
end

detect_precursor(path; inst, mode, V, r, zs, ε, τ, folds, fmts, subdir, out) = begin
    fname_m2 = splitext(path)[1] * ".ms2"
    @info "MS2 loading from " * fname_m2
    M2 = MesMS.read_ms2(fname_m2)

    fname_m1 = splitext(path)[1] * ".ms1"
    @info "MS1 loading from " * fname_m1
    M1 = MesMS.read_ms1(fname_m1)
    prepend!(M1, [MesMS.MS1(id=typemin(Int)) for i in 1:8])
    append!(M1, [MesMS.MS1(id=typemax(Int)) for i in 1:8])
    @info "MS1 slicing"
    M1 = slice_ms1(M1, M2, r)

    @info "evaluating"
    I = @showprogress map(zip(M1, M2)) do (ms1, ms2)
        r_ = isnan(r) ? ms2.isolation_width / 2 : r
        ions = evaluate(ms1[8:9], ms2.activation_center, r_, zs, ε, V, τ, mode)
        if inst
            ions = filter(i -> !any(x -> i.z == x.z && MesMS.in_moe(i.mz, x.mz, ε), ms2.ions), ions)
            append!(ions, [(; i.mz, i.z, score=Inf) for i in ms2.ions])
        end
        return sort(ions; by=i -> i.score, rev=true)
    end
    for fold in folds
        @info "filtering by $(fold)-fold"
        I_ = filter_by_fold(I, fold)

        @info "fine-tuning"
        I_ = @showprogress map(zip(I_, M1)) do (ions, ms1)
            map(ion -> tune_mass(ion, ms1, ε / 2), ions)
        end

        report_ions(I_, map(m -> m.ions, M2), ε)
        name = basename(splitext(path)[1])
        for fmt in fmts
            ext = fmt ∈ ["csv", "tsv"] ? "precursor.$(fmt)" : fmt
            path_out = joinpath(subdir ? joinpath(out, "$(fold)") : out, "$(name).$(ext)")
            mkpath(dirname(path_out))
            @info "result saving to " * path_out
            open(io -> write_ions(fmt, io, M2, I_; name), path_out * "~"; write=true)
            mv(path_out * "~", path_out; force=true)
        end
    end
end

main() = begin
    settings = ArgParse.ArgParseSettings(prog="PepPre")
    ArgParse.@add_arg_table! settings begin
        "--inst"
            help = "preserve original (instrument) ions"
            action = :store_true
        "--mode"
            help = "by mono or max mode"
            metavar = "mono|max"
            default = "mono"
        "--ipv"
            help = "IPV file"
            metavar = "IPV"
            default = joinpath(homedir(), ".MesMS/IPV.bson")
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
        "--fmt", "-f"
            help = "output format"
            metavar = "csv,tsv,ms2,mgf"
            default = "ms2"
        "--out", "-o"
            help = "output directory"
            metavar = "output"
            default = "./out/"
        "data"
            help = "list of .ms2 files or directories; .ms1 files should be in the same directory"
            nargs = '+'
            required = true
    end
    args = ArgParse.parse_args(settings)
    paths = (sort∘unique∘reduce)(vcat, MesMS.match_path.(args["data"], ".ms2"); init=String[])
    @info "file paths of selected data:"
    foreach(x -> println("$(x[1]):\t$(x[2])"), enumerate(paths))
    sess = prepare(args)
    detect_precursor.(paths; sess...)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

julia_main()::Cint = begin
    main()
    return 0
end

include("PepPreView.jl")

main_PepPre()::Cint = julia_main()
main_PepPreView()::Cint = PepPreView.julia_main()

end
