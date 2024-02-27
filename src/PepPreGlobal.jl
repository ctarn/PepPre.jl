module PepPreGlobal

using Distributed

import ArgParse
import CSV
import ProgressMeter: @showprogress
import UniMS: UniMS, PepIso

prepare(args) = begin
    out = mkpath(args["out"])
    V = UniMS.build_ipv(args["ipv"])
    n_peak = parse(Int, args["peak"])
    zs = Vector{Int}(UniMS.parse_range(Int, args["charge"]))
    ε = parse(Float64, args["error"]) * 1.0e-6
    τ = parse(Float64, args["thres"])
    gap = parse(Int, args["gap"])
    addprocs(parse(Int, args["proc"]))
    @eval @everywhere using PepPre.PepPreGlobal
    return (; out, V, n_peak, zs, ε, τ, gap)
end

process(path; out, V, n_peak, zs, ε, τ, gap) = begin
    M = UniMS.read_ms(path; MS2=false).MS1
    @info "deisotoping"
    I = @showprogress pmap(M) do m
        peaks = UniMS.pick_by_inten(m.peaks, n_peak)
        ions = [UniMS.Ion(p.mz, z) for p in peaks for z in zs]
        ions = filter(i -> i.mz * i.z < UniMS.ipv_max(V) && PepIso.prefilter(i, peaks, ε, V), ions)
        ions = PepIso.deisotope(ions, peaks, τ, ε, V; split=true)
        return [(; ion..., ms=m) for ion in ions]
    end
    G = PepIso.group_ions(I, gap, ε)
    d = Dict{Int, Int}()
    foreach(l -> d[l] = get(d, l, 0) + 1, length.(G))
    foreach(k -> println("$(k)\t$(get(d, k, 0))"), minimum(keys(d)):100)
    @info "analysing"
    P = @showprogress map(ions -> PepIso.build_precursor(ions, ε, V), G)
    P = [(; id=i, f...) for (i, f) in enumerate(P)]
    UniMS.safe_save(p -> CSV.write(p, P), joinpath(out, splitext(basename(path))[1] * ".precursor.csv"))
end

main() = begin
    settings = ArgParse.ArgParseSettings(prog="PepPreGlobal")
    ArgParse.@add_arg_table! settings begin
        "data"
            help = "list of .mes or .ms1 files"
            nargs = '+'
            required = true
        "--out", "-o"
            help = "output directory"
            metavar = "./out/"
            default = "./out/"
        "--ipv"
            help = "Isotope Pattern Vector file"
            metavar = "IPV"
            default = joinpath(homedir(), ".UniMS/peptide.ipv")
        "--peak", "-p"
            help = "max #peak per scan"
            metavar = "num"
            default = "4000"
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
            metavar = "threshold"
            default = "1.0"
        "--gap", "-g"
            help = "scan gap"
            metavar = "gap"
            default = "16"
        "--proc"
            help = "number of additional worker processes"
            metavar = "n"
            default = "4"
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
