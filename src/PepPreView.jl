module PepPreView

using Sockets

import ArgParse
import CSV
import DataFrames
import MesMS: MesMS, PepIso
import MesUtil: pFind
import ProgressMeter: @showprogress
import RelocatableFolders: @path

using Dash
using PlotlyBase

const DIR_DATA = @path joinpath(@__DIR__, "../data/dash")

iw_trace(mz, mz_w, h) = begin
    x1 = mz - mz_w / 2
    x2 = mz + mz_w / 2
    return (
        x=[x1, x1, x2, x2, x1, nothing, mz, mz],
        y=[0.85h, 0.75h, 0.75h, 0.85h, 0.85h, nothing, 0.7h, 0.9h],
    )
end

run_peppre(peaks, mz, r, zs, ε, V, τ; mode=:mono) = begin
    δs = map(zs) do z
        if mode == :mono return 0.0 end
        # else max mode
        m = mz * z
        i = argmax(MesMS.ipv_w(m, V))
        return (MesMS.ipv_m(m, V)[i] - MesMS.ipv_m(m, V)[1]) / z
    end
    ions = [MesMS.Ion(p.mz - δ, z) for p in peaks for (z, δ) in zip(zs, δs)]
    ions = filter(i -> i.mz * i.z < MesMS.ipv_max(V) && PepIso.prefilter(i, peaks, ε, V, mode), ions)
    ions = PepIso.deisotope(ions, peaks, τ, ε, V)
    inten = sum(p -> p.inten, MesMS.query(peaks, mz - r, mz + r), init=1.0e-16)
    ions = map(ions) do ion
        ratio = sum(MesMS.ipv_w(ion, V)[MesMS.argquery_δ(MesMS.ipv_mz(ion, V), mz, r)], init=0.0)
        return (; ion.mz, ion.z, score=(ion.m * ion.x * ratio / inten), score_m=ion.m, score_x=ion.x, ratio, inten)
    end
    return sort(filter(i -> i.score > 0, ions); rev=true, by=i -> i.score)
end

plot_peppre(ps, mz, mz_w, ions, df_psm, ε, V) = begin
    ls = map(ps) do p
        scatter(x=[p.mz, p.mz], y=[0, p.inten],
            mode="lines", line_color="black", name="", showlegend=false,
        )
    end
    max_inten = MesMS.max_inten(ps, 0, Inf)
    push!(ls, scatter(;
        iw_trace(mz, mz_w, max_inten)...,
        mode="lines", line_dash="dash", line_color="red", name="isolation window",
    ))
    for r in eachrow(df_psm)
        push!(ls, scatter(;
            x=[r.mz], y=[MesMS.max_inten_ε(ps, r.mz, ε)], mode="markers+text", name="PSM#$(r.id)",
            text=["#$(r.id)"], hovertext=["$(pFind.pepstr(r.pep, r.mod))"], textposition="top",
        ))
    end
    for (idx, i) in enumerate(ions)
        xs, ys = MesMS.ipv_mz(i, V), -MesMS.ipv_w(i, V) .* i.score_x
        xs_, ys_ = [], []
        for (x, y) in zip(xs, ys)
            append!(xs_, [x, x, nothing])
            append!(ys_, [0, y, nothing])
        end
        push!(ls, scatter(; x=xs_, y=ys_, mode="lines", hovertext="score=$(i.score)", name="Ion#$(idx)"))
    end
    p = Plot(ls, Layout(; xaxis_title="m/z", yaxis_title="abundance", showlegend=true))
    return p
end

tab_ms2_names = Dict([
    "file" => "File",
    "id" => "Scan No.",
    "pre" => "Master Scan No.",
    "rt" => "Retention Time (s)",
    "mz" => "Activation Center (Th)",
    "mz_w" => "Isolation Width (Th)",
    "n_psm" => "#PSM",
])

tab_psm_names = Dict([
    "id" => "PSM ID",
    "mh" => "M+H Mass (Da)",
    "mz" => "m/z (Th)",
    "z" => "Charge State",
    "pep" => "Sequence",
    "mod" => "Modification",
    "prot" => "Protein",
    "error" => "Precursor Mass Error (ppm)",
    "title" => "Spectrum Title",
    "file" => "File",
    "scan" => "Scan No.",
    "q_value" => "q-value",
    "score" => "PSM Score",
])

build_app(df_ms1, df_ms2, di_ms1, di_ms2, df_psm, ele_pfind, aa_pfind, mod_pfind, V) = begin
    df_ms2_tab = DataFrames.select(df_ms2, DataFrames.Not(["psm", "ms"]))
    sort!(df_ms2_tab, :n_psm; rev=true)
    app = dash(; assets_folder=DIR_DATA)
    app.layout = html_div() do
        html_h1("PepPreView", style=Dict("text-align"=>"center")),
        dash_datatable(
            id="tab_ms2",
            style_table=Dict("min-width"=>"100%", "overflow-x"=>"auto"),
            style_cell=Dict("overflow"=>"hidden", "text-overflow"=>"ellipsis", "min-width"=>"64px", "max-width"=>"256px"),
            columns=[(; name=tab_ms2_names[i], id=i) for i in names(df_ms2_tab) if haskey(tab_ms2_names, i)],
            data=Dict.(pairs.(eachrow(df_ms2_tab))),
            filter_action="native",
            sort_action="native",
            sort_mode="multi",
            row_selectable="single",
            page_action="native",
            page_size=10,
        ),
        html_div(className="opts") do
            html_div(className="opt") do
                html_span("m/z error:", className="name"),
                html_div(className="value") do
                    dcc_input(id="error", className="input", value=10.0, type="number", placeholder="error"),
                    html_span("ppm", className="unit")
                end
            end,
            html_div(className="opt") do
                html_span("exclusion threshold:", className="name"),
                html_div(className="value") do
                    dcc_input(id="exclusion", className="input", value=1.0, type="number", placeholder="≥0")
                end
            end,
            html_div(className="opt") do
                html_span("score threshold:", className="name"),
                html_div(className="value") do
                    dcc_input(id="score", className="input", value=0.0, type="number", placeholder="≥0")
                end
            end,
            html_div(className="opt") do
                html_span("charge state:", className="name"),
                dcc_rangeslider(id="charge", className="charge_slider", min=1, max=12, step=1, value=[2, 6], marks=Dict([i=>"$(i)+" for i in 1:12]))
            end
        end,
        # have to set the height manually currently, otherwise the graph can be hidden
        dcc_graph(id="fig_ion", style=Dict("height"=>"450px")),
        dash_datatable(
            id="tab_psm",
            style_table=Dict("min-width"=>"100%", "overflow-x"=>"auto"),
            style_cell=Dict("overflow"=>"hidden", "text-overflow"=>"ellipsis", "min-width"=>"64px", "max-width"=>"256px"),
            columns=[(; name=tab_psm_names[i], id=i) for i in names(df_psm) if haskey(tab_psm_names, i)],
            filter_action="native",
            sort_action="native",
            sort_mode="multi",
            row_selectable="single",
            page_action="native",
            page_size=10,
        ),
        html_div(className="opts") do
            html_div(className="opt") do
                html_span("fragment m/z error:", className="name"),
                html_div(className="value") do
                    dcc_input(id="error_frag", className="input", value=10.0, type="number", placeholder="error"),
                    html_span("ppm", className="unit")
                end
            end
        end,
        dcc_graph(id="fig_seq"),
        dcc_graph(id="fig_psm")
    end

    callback!(app,
        Output("tab_psm", "data"),
        Output("fig_ion", "figure"),
        Output("fig_ion", "config"),
        Input("tab_ms2", "derived_virtual_data"),
        Input("tab_ms2", "derived_virtual_selected_rows"),
        Input("error", "value"),
        Input("exclusion", "value"),
        Input("score", "value"),
        Input("charge", "value"),
    ) do v1, v2, ε, τ, s, zs
        r = v1[v2[begin] + 1]
        ms2 = df_ms2[di_ms2[(r.file, r.id)], :]
        ms1 = df_ms1[di_ms1[(ms2.file, ms2.pre)], :]
        ε = ε * 1.0e-6
        zs = range(zs[1], zs[2])
        ps = MesMS.query(ms1.ms.peaks, ms2.mz - ms2.mz_w / 2 * 2 - 2, ms2.mz + ms2.mz_w / 2 * 2)
        ions = run_peppre(ps, ms2.mz, ms2.mz_w / 2, zs, ε, V, τ)
        filter!(i -> i.score ≥ s, ions)
        fig = plot_peppre(ps, ms2.mz, ms2.mz_w, ions, df_psm[ms2.psm, :], ε, V)
        table_data = Dict.(pairs.(eachrow(df_psm[ms2.psm, :])))
        for i in table_data
            i[:mod] = pFind.modstr(i[:mod])
        end
        cfg = PlotConfig(toImageButtonOptions=attr(format="svg", filename="PepPre_$(r.file)_$(r.id)").fields)
        return table_data, fig, cfg
    end

    callback!(app,
        Output("fig_seq", "figure"),
        Output("fig_seq", "config"),
        Output("fig_psm", "figure"),
        Output("fig_psm", "config"),
        Input("tab_psm", "derived_virtual_data"),
        Input("tab_psm", "derived_virtual_selected_rows"),
        Input("error_frag", "value"),
    ) do v1, v2, ε
        r = v1[v2[begin] + 1]
        r = df_psm[r.id, :]
        ε = ε * 1.0e-6
        ms2 = df_ms2[di_ms2[(r.file, r.scan)], :]
        ions = MesMS.Plot.build_ions(ms2.ms.peaks, r.pep, r.mod, ε, ele_pfind, aa_pfind, mod_pfind)
        fig_seq = MesMS.Plotly.seq(r.pep, r.mod, ions)
        fig_psm = MesMS.Plotly.spec(ms2.ms.peaks, filter(i -> i.peak > 0, ions))
        cfg_seq = PlotConfig(toImageButtonOptions=attr(format="svg", filename="PepPre_seq_$(r.file)_$(r.scan)_$(r.id)").fields)
        cfg_psm = PlotConfig(toImageButtonOptions=attr(format="svg", filename="PepPre_psm_$(r.file)_$(r.scan)_$(r.id)").fields)
        return fig_seq, cfg_seq, fig_psm, cfg_psm
    end
    return app
end

prepare(args) = begin
    host = parse(IPAddr, args["host"])
    port = parse(Int, args["port"])
    V = MesMS.build_ipv(args["ipv"])
    path_cfg = args["cfg"]
    if isempty(path_cfg)
        ele_pfind = pFind.read_element() |> NamedTuple
        aa_pfind = map(x -> MesMS.mass(x, ele_pfind), pFind.read_amino_acid() |> NamedTuple)
        mod_pfind = MesMS.mapvalue(x -> x.mass, pFind.read_mod())
    else
        ele_pfind = pFind.read_element(joinpath(path_cfg, "element.ini")) |> NamedTuple
        aa_pfind = map(x -> MesMS.mass(x, ele_pfind), pFind.read_amino_acid(joinpath(path_cfg, "aa.ini")) |> NamedTuple)
        mod_pfind = MesMS.mapvalue(x -> x.mass, pFind.read_mod(joinpath(path_cfg, "modification.ini")))
    end
    path_psm = args["psm"]
    return (; host, port, V, ele_pfind, aa_pfind, mod_pfind, path_psm)
end

process(paths; host, port, V, ele_pfind, aa_pfind, mod_pfind, path_psm) = begin
    Ms = map(MesMS.read_ms, paths)
    df_ms1 = map(reduce(vcat, getfield.(Ms, :MS1))) do m
        (; file, m.id, rt=m.retention_time, ms=m)
    end |> DataFrames.DataFrame
    df_ms2 = map(reduce(vcat, getfield.(Ms, :MS2))) do m
        (; file, m.id, m.pre, rt=m.retention_time, mz=m.activation_center, mz_w=m.isolation_width, ms=m)
    end |> DataFrames.DataFrame

    sort!(df_ms1, [:file, :id])
    sort!(df_ms2, [:file, :id])

    di_ms1 = [(r.file, r.id) => i for (i, r) in enumerate(eachrow(df_ms1))] |> Dict
    di_ms2 = [(r.file, r.id) => i for (i, r) in enumerate(eachrow(df_ms2))] |> Dict

    df_psm = pFind.read_psm(path_psm)
    ns = [
        "Scan_No", "Sequence", "mh_calc", "Mass_Shift(Exp.-Calc.)", "score_raw", "Modification",
        "Specificity", "Positions", "Label", "Miss.Clv.Sites", "Avg.Frag.Mass.Shift", "Others", "mz_calc"
    ]
    DataFrames.select!(df_psm, DataFrames.Not(filter(x -> x ∈ names(df_psm), ns)))
    ns = [
        "mh", "mz", "z", "pep", "mod", "prot", "error", "title", "file", "scan", "idx_pre",
    ]
    DataFrames.select!(df_psm, ns, DataFrames.Not(ns))

    df_psm.id = 1:size(df_psm, 1)
    DataFrames.select!(df_psm, :id, DataFrames.Not([:id]))
    df_psm.rt = [df_ms2[di_ms2[(r.file, r.scan)], :rt] for r in eachrow(df_psm)]

    df_ms2.psm = [df_psm[(df_psm.scan .== r.id) .&& (df_psm.file .== r.file), :id] for r in eachrow(df_ms2)]
    df_ms2.n_psm = length.(df_ms2.psm)
    @async begin
        sleep(4)
        MesMS.open_url("http://$(host):$(port)")
    end
    app = build_app(df_ms1, df_ms2, di_ms1, di_ms2, df_psm, ele_pfind, aa_pfind, mod_pfind, V)
    run_server(app, host, port)
end

main() = begin
    settings = ArgParse.ArgParseSettings(prog="PepPreView")
    ArgParse.@add_arg_table! settings begin
        "--host"
            help = "hostname"
            metavar = "hostname"
            default = "127.0.0.1"
        "--port"
            help = "port"
            metavar = "port"
            default = "30030"
        "--ipv"
            help = "IPV file"
            metavar = "IPV"
            default = joinpath(homedir(), ".MesMS/peptide.ipv")
        "--cfg"
            help = "pFind config directory"
            default = ""
        "--psm"
            help = "pFind PSM path"
            required = true
        "data"
            help = "list of .mes or .ms1/2 files; .ms2/1 files should be in the same directory for .ms1/2"
            nargs = '+'
            required = true
    end
    args = ArgParse.parse_args(settings)
    paths = (sort∘unique∘reduce)(vcat, MesMS.match_path.(args["data"], ".ms2"); init=String[])
    @info "file paths of selected data:"
    foreach(x -> println("$(x[1]):\t$(x[2])"), enumerate(paths))
    process(paths; prepare(args)...)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

julia_main()::Cint = main()

end
