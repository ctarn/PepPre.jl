module PepPreAlign

using Statistics

import ArgParse
import CSV
import DataFrames
import MesMS
import ProgressMeter: @showprogress
import RelocatableFolders: @path

const DIR_DATA = @path joinpath(@__DIR__, "../data")

prepare(args) = begin
    @info "reference loading from " * args["ref"]
    df_ref = args["ref"] |> CSV.File |> DataFrames.DataFrame
    out = mkpath(args["out"])
    len_rt = parse(Float64, args["len_rt"])
    ε_m = parse(Float64, args["error_mz"]) * 1e-6
    ε_t = parse(Float64, args["error_rt"])
    bin_size = parse(Float64, args["bin"])
    α = parse(Float64, args["factor"])
    softer = MesMS.exp_softer(parse(Float64, args["scale"]))

    df_ref = df_ref[df_ref.rtime_len .≥ len_rt, :]
    DataFrames.sort!(df_ref, :mz)
    return (; df_ref, out, len_rt, ε_m, ε_t, bin_size, α, softer)
end

process(path; df_ref, out, len_rt, ε_m, ε_t, bin_size, α, softer) = begin
    @info "precursor list loading from " * path
    df = path |> CSV.File |> DataFrames.DataFrame
    df.matched .= false
    df.match_id .= 0
    df.rtime_aligned .= Inf
    df.delta_rt .= Inf
    df.delta_rt_aligned .= Inf
    df.delta_mz .= Inf
    df.delta_abu .= Inf
    df.bin = round.(Int, df.rtime ./ bin_size)
    bin_min, bin_max = extrema(df.bin)
    bins = [Int[] for _ in (bin_min-1):(bin_max+1)]
    Δs = zeros(length(bins))
    Δidx = bin_min - 2
    df.bin_idx = df.bin .- Δidx
    @showprogress for (i, idx) in enumerate(df.bin_idx)
        push!(bins[idx], i)
    end
    referable = trues(size(df_ref, 1))
    @showprogress for i_b in 2:(length(bins)-1)
        δs = Float64[]
        for i_f in bins[i_b]
            a = df[i_f, :]
            a.rtime_aligned = a.rtime + Δs[i_b-1]
            if a.rtime_len < len_rt continue end
            idx = filter(MesMS.argquery_ε(df_ref.mz, a.mz, ε_m)) do i
                referable[i] && df_ref[i, :z] == a.z && abs(df_ref[i, :rtime] - a.rtime_aligned) ≤ ε_t
            end
            if isempty(idx) continue end
            _, i = findmin(x -> abs(df_ref[x, :rtime] - a.rtime_aligned), idx)
            referable[idx[i]] = false
            b = df_ref[idx[i], :]
            δ = b.rtime - a.rtime
            push!(δs, δ)
            a.matched = true
            a.match_id = b.id # may not equal to `i`
            a.delta_rt = δ
            a.delta_rt_aligned = b.rtime - a.rtime_aligned
            a.delta_mz = MesMS.error_ppm(a.mz, b.mz)
            a.delta_abu = b.inten_apex / a.inten_apex
        end
        Δs[i_b] = Δs[i_b-1] + (isempty(δs) ? 0 : α * mean(softer.(δs .- Δs[i_b-1])))
    end
    fname = splitext(basename(path))[1]
    MesMS.safe_save(p -> CSV.write(p, df), joinpath(out, fname * "_aligned.csv"))

    df_shift = DataFrames.DataFrame(time=Vector((bin_min:bin_max) * bin_size), shift=Δs[begin+1:end-1])
    MesMS.safe_save(p -> CSV.write(p, df_shift), joinpath(out, fname * "_shift.csv"))

    df_matched = df[df.matched, :]
    data = """
const TIME = [$(join(string.(df_shift.time), ","))]
const SHIFT = [$(join(string.(df_shift.shift), ","))]
const RT_MATCH = [$(join(string.(df_matched.rtime), ","))]
const DELTA_RT_MATCH = [$(join(string.(df_matched.delta_rt), ","))]
    """
    html = read(joinpath(DIR_DATA, "template.html"), String)
    html = replace(html,
        "{{ name }}" => basename(path),
        "{{ chartjs }}" => read(joinpath(DIR_DATA, "chartjs-4.2.1.js"), String),
        "{{ data }}" => data,
    )
    MesMS.safe_save(p -> write(p, html), joinpath(out, fname * ".html"))
    MesMS.open_url(joinpath(out, fname * ".html"))
end

main() = begin
    settings = ArgParse.ArgParseSettings(prog="PepPreAlign")
    ArgParse.@add_arg_table! settings begin
        "data"
            help = "precursor list"
            nargs = '+'
            required = true
        "--ref", "--to"
            help = "referred precursor list"
            metavar = "reference"
            required = true
        "--out", "-o"
            help = "output directory"
            metavar = "./out/"
            default = "./out/"
        "--len_rt", "-l"
            help = "min retention time length"
            metavar = "second"
            default = "4.0"
        "--error_mz", "-m"
            help = "m/z error"
            metavar = "ppm"
            default = "1.0"
        "--error_rt", "-t"
            help = "max retention time error"
            metavar = "second"
            default = "600.0"
        "--bin", "-b"
            help = "moving average step (or, bin size)"
            metavar = "second"
            default = "1.0"
        "--factor", "-f"
            help = "moving average factor (or, updating rate)"
            metavar = "factor"
            default = "0.1"
        "--scale", "-s"
            help = "moving average scale"
            metavar = "scale"
            default = "64"
    end
    args = ArgParse.parse_args(settings)
    paths = reduce(vcat, MesMS.match_path.(args["data"], ".csv")) |> unique |> sort
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
