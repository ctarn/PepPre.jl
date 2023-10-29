module PepPreGlobal

using Distributed
using Statistics

import ArgParse
import CSV
import MesMS: MesMS, PepIso
import ProgressMeter: @showprogress

check_iso(ion, spec, ε, V) = map(x -> !isempty(MesMS.query_ε(spec, x, ε)), MesMS.ipv_mz(ion, V))

build_precursor(ions, ε, V) = begin
    apex = argmax(i -> i.x, ions)
    # mass
    mz = sum(i -> i.mz * i.x, ions) / sum(i -> i.x, ions)
    z = ions[begin].z
    mh = MesMS.mz_to_mh(mz, z)
    mz_max = MesMS.ipv_mz(mz, z, argmax(MesMS.ipv_w(apex, V)), V)
    # retention time
    rtime, _ = MesMS.centroid(map(i -> i.ms.retention_time, ions), map(i -> i.x, ions))
    rtime_start, rtime_stop = extrema(i -> i.ms.retention_time, ions)
    rtime_len = rtime_stop - rtime_start
    rtime_apex = apex.ms.retention_time
    half = map(i -> i.x * 2 > apex.x, ions)
    fwhm = ions[findlast(half)].ms.retention_time - ions[findfirst(half)].ms.retention_time
    # scan
    scan_start, scan_stop = extrema(i -> i.ms.id, ions)
    scan_num = length(ions)
    scan_apex = apex.ms.id
    # intensity
    inten_sum = sum(i -> i.x, ions)
    inten_apex = apex.x
    # isotope
    iso_shape_apex = apex.m
    iso_shape_mean = mean(i -> i.m, ions)
    iso_apex = check_iso(apex, apex.ms.peaks, ε, V)
    iso_num_apex = sum(iso_apex)
    iso_last_apex = findlast(iso_apex)
    iso_apex_str = join(Int.(iso_apex[begin:findlast(iso_apex)]))
    iso = map(i -> check_iso(i, i.ms.peaks, ε, V), ions)
    iso_str = map(i -> join(Int.(i[begin:findlast(i)])), iso)
    iso_num = map(sum, iso)
    iso_num_max = maximum(iso_num)
    iso_last = map(findlast, iso)
    iso_last_max = maximum(iso_last)
    # precursor ion fraction
    inten_window = sum(p -> p.inten, MesMS.query(apex.ms.peaks, (1 - 2ε) * apex.mz, (1 + 2ε) * MesMS.ipv_mz(apex, iso_last_apex, V)))
    inten_rate = apex.x / inten_window
    return (; mh, mz, z, mz_max,
        rtime, rtime_start, rtime_stop, rtime_len, rtime_apex, fwhm, scan_start, scan_stop, scan_num, scan_apex,
        inten_apex, inten_sum, inten_rate, inten_window, iso_shape_apex, iso_shape_mean,
        iso_apex_str, iso_num_apex, iso_last_apex, iso_num_max, iso_last_max, iso_str, iso_num, iso_last,
    )
end

prepare(args) = begin
    out = mkpath(args["out"])
    V = MesMS.build_ipv(args["ipv"])
    n_peak = parse(Int, args["peak"])
    zs = Vector{Int}(MesMS.parse_range(Int, args["charge"]))
    ε = parse(Float64, args["error"]) * 1.0e-6
    τ = parse(Float64, args["thres"])
    gap = parse(Int, args["gap"])
    addprocs(parse(Int, args["proc"]))
    @eval @everywhere using PepPre.PepPreGlobal
    return (; out, V, n_peak, zs, ε, τ, gap)
end

process(path; out, V, n_peak, zs, ε, τ, gap) = begin
    M = MesMS.read_ms(path; MS2=false).MS1
    @info "deisotoping"
    I = @showprogress pmap(M) do m
        peaks = MesMS.pick_by_inten(m.peaks, n_peak)
        ions = [MesMS.Ion(p.mz, z) for p in peaks for z in zs]
        ions = filter(i -> i.mz * i.z < MesMS.ipv_max(V) && PepIso.prefilter(i, peaks, ε, V), ions)
        ions = PepIso.deisotope(ions, peaks, τ, ε, V; split=true)
        ions = [(; ion..., ms=m) for ion in ions]
    end
    G = PepIso.group_ions(I, gap, ε)
    d = Dict{Int, Int}()
    foreach(l -> d[l] = get(d, l, 0) + 1, map(length, G))
    foreach(k -> println("$(k)\t$(get(d, k, 0))"), minimum(keys(d)):100)
    @info "analysing"
    F = @showprogress map(G) do ions
        build_precursor(ions, ε, V)
    end
    F = [(; id=i, f...) for (i, f) in enumerate(F)]
    MesMS.safe_save(p -> CSV.write(p, F), joinpath(out, splitext(basename(path))[1] * ".precursor.csv"))
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
            default = joinpath(homedir(), ".MesMS/peptide.ipv")
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
    paths = reduce(vcat, MesMS.match_path.(args["data"], ".mes")) |> unique |> sort
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
