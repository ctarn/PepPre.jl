module PepPre

using Base: Filesystem

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
    n̂ = sum(x -> length(x), Î)
    n = sum(x -> length(x), I)
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
    println("-"^16)
    println("#ion\t#MS2")
    println("-"^16)
    foreach(k -> println("$(k)\t$(get(fs, k, 0))"), minimum(keys(fs)):maximum(keys(fs)))
    println("-"^16)
    println("charge\t#ion")
    println("-"^16)
    foreach(k -> println("$(k)+\t$(get(zs, k, 0))"), minimum(keys(zs)):maximum(keys(zs)))
    println("-"^16)
    println("mass\t#ion")
    println("-"^16)
    foreach(k -> println("$(k)k Da\t$(get(ms, k, 0))"), minimum(keys(ms)):maximum(keys(ms)))
    println("-"^16)
    println("#ion: $(n) -> $(n̂) ($(round(n / length(I), digits=2))× -> $(round(n̂ / length(I), digits=2))×)")
    println("kept: $(kept) / $(length(I)) = $(round(kept / length(I) * 100, digits=2))%")
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

evaluate(ms1, mz, r, zs, ε, V, τ, max_mode=false) = begin
    δs = map(zs) do z
        m = mz * z
        i = argmax(MesMS.ipv_w(m, V))
        return max_mode ? (MesMS.ipv_m(m, V)[i] - MesMS.ipv_m(m, V)[1]) / z : 0.0
    end
    ions = map(ms1) do spec
        peaks = MesMS.query(spec, mz - r - 2, mz + r + 1)
        ions = [MesMS.Ion(p.mz - δ, z) for p in peaks for (z, δ) in zip(zs, δs)]
        ions = filter(i -> i.m < length(V) && PepIso.prefilter(i, spec, ε, V, max_mode), ions)
        ions = PepIso.deisotope(ions, spec, τ, ε, V, :LP)
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

tune_mass(ion, ms1, ε) = begin
    peaks = map(ms1) do spec
        l, r = searchsortedfirst(spec, (1 - ε) * ion.mz), searchsortedlast(spec, (1 + ε) * ion.mz)
        εs = map(p -> abs(ion.mz - p.mz), spec[l:r])
        return l <= r ? spec[argmin(εs)+l-1] : MesMS.Peak(0.0, 0.0)
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

detect_precursor(path, args) = begin
    max_mode = args["max"]::Bool
    preserve = args["i"]::Bool
    r = args["w"] == "auto" ? NaN : parse(Float64, args["w"]) / 2
    ε = parse(Float64, args["e"]) * 1.0e-6
    τ_exclusion = parse(Float64, args["t"])
    fs = Vector{Float64}(MesMS.parse_range(Float64, args["n"]))
    zs = Vector{Int}(MesMS.parse_range(Int, args["z"]))
    fname = splitext(path)[1]

    V = MesMS.build_ipv(args["m"])

    fname_m2 = fname * ".ms2"
    @info "MS2 loading from " * fname_m2
    M2 = MesMS.read_ms2(fname_m2)

    fname_m1 = fname * ".ms1"
    @info "MS1 loading from " * fname_m1
    M1 = MesMS.read_ms1(fname_m1)
    prepend!(M1, [MesMS.MS1(id=typemin(Int)) for i in 1:8])
    append!(M1, [MesMS.MS1(id=typemax(Int)) for i in 1:8])
    @info "MS1 slicing"
    M1 = slice_ms1(M1, M2, r)

    @info "evaluating"
    I = @showprogress map(zip(M1, M2)) do (ms1, ms2)
        r_ = isnan(r) ? ms2.isolation_width / 2 : r
        ions = evaluate(ms1[8:9], ms2.activation_center, r_, zs, ε, V, τ_exclusion, max_mode)
        if preserve
            ions = filter(i -> !any(x -> i.z == x.z && MesMS.in_moe(i.mz, x.mz, ε), ms2.ions), ions)
            append!(ions, [(; i.mz, i.z, score=Inf) for i in ms2.ions])
        end
        return sort(ions; by=i -> i.score, rev=true)
    end

    subdir = ':' ∈ args["n"]
    for fold in fs
        @info "filtering by $(fold)-fold"
        I_ = filter_by_fold(I, fold)

        @info "fine-tuning"
        I_ = @showprogress map(zip(I_, M1)) do (ions, ms1)
            map(ion -> tune_mass(ion, ms1, ε / 2), ions)
        end

        report_ions(I_, map(m -> m.ions, M2), ε)
        name = basename(fname)
        for fmt in split(args["f"], ",")
            path_out = joinpath(subdir ? joinpath(args["o"], "$(fold)") : args["o"], "$(name).$(fmt)")
            mkpath(dirname(path_out))
            @info "result saving to " * path_out
            open(io -> write_ions(fmt, io, M2, I_; name), path_out * "~", write=true)
            mv(path_out * "~", path_out; force=true)
        end
    end
end

main() = begin
    settings = ArgParse.ArgParseSettings(prog="PepPre")
    ArgParse.@add_arg_table! settings begin
        "--max"
            help = "max mode"
            action = :store_true
        "-i"
            help = "preserve original (instrument) ions"
            action = :store_true
        "-m"
            help = "model file"
            metavar = "model"
            default = joinpath(homedir(), ".MesMS/IPV.bson")
        "-t"
            help = "exclusion threshold"
            metavar = "threshold"
            default = "1.0"
        "-e"
            help = "m/z error"
            metavar = "ppm"
            default = "10.0"
        "-w"
            help = "isolation width"
            metavar = "width"
            default = "auto"
        "-z"
            help = "charge states"
            metavar = "min:max"
            default = "2:6"
        "-n"
            help = "number of precursor ions"
            metavar = "fold"
            default = "4.0"
        "-f"
            help = "output format"
            metavar = "csv,tsv,ms2,mgf"
            default = "ms2"
        "-o"
            help = "output directory"
            metavar = "output"
            default = "./out/"
        "data"
            help = "list of .ms2 files"
            nargs = '+'
            required = true
    end
    args = ArgParse.parse_args(settings)
    for path in args["data"], file in readdir(dirname(path))
        if file == basename(path) || (startswith(file, basename(path)) && endswith(file, ".ms2"))
            detect_precursor(joinpath(dirname(path), file), args)
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

julia_main()::Cint = begin
    main()
    return 0
end

end
