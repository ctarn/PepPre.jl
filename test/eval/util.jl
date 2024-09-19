using Printf
using Statistics

import DataFrames
import UniMZ
import UniMZ: PyPlot, PyPlot.mpl, PyPlot.plt, PyPlot.plt_venn
import UniMZUtil: pFind, pLink
import ProgressMeter: @showprogress
import PyCall: @py_str

ROOT = begin
    if Sys.isapple()
        "/Volumes/E-Disk/Data/PepPre/"
    elseif Sys.iswindows()
        joinpath(homedir(),  "OneDrive/Data/PepPre/")
    else
        ""
    end
end

Global_V = UniMZ.build_ipv()

check_prot(cols, prots) = begin
    reduce(.&, map(c -> map(x -> any(p -> p[1] ∈ prots, x), c), cols))
end

calc_ion_pfind(df, M2, ε=20e-6) = begin
    tab_ele = pFind.read_element() |> NamedTuple
    tab_aa = map(x -> UniMZ.mass(x, tab_ele), pFind.read_amino_acid() |> NamedTuple)
    tab_mod = map(x -> x.mass, pFind.read_modification() |> NamedTuple)
    @info "Norm. num. of ions calculating"
    @showprogress map(eachrow(df)) do row
        m2 = M2[row.file][row.scan]
        ions = UniMZ.build_ions(m2.peaks, row.pep, row.mod, ε, tab_ele, tab_aa, tab_mod)
        ions = filter(i -> i.peak > 0, ions)
        return length(ions) / (length(row.pep))
    end
end

calc_ion_plink(df, M2, ε=20e-6) = begin
    tab_ele = pLink.read_element() |> NamedTuple
    tab_aa = map(x -> UniMZ.mass(x, tab_ele), pLink.read_amino_acid() |> NamedTuple)
    tab_mod = map(x -> x.mass, pLink.read_modification() |> NamedTuple)
    linkers = pLink.read_linker() |> NamedTuple
    @info "Norm. num. of ions calculating"
    @showprogress map(eachrow(df)) do row
        peps = (row.pep_a, row.pep_b)
        mods = (row.mod_a, row.mod_b)
        sites = (row.site_a, row.site_b)
        m2 = M2[row.file][row.scan]
        linker = linkers[row.linker]
        ionss = UniMZ.build_ions_crosslink(m2.peaks, peps, mods, linker, sites, ε, tab_ele, tab_aa, tab_mod)
        ionss = map(ions -> filter(i -> i.peak > 0, ions), ionss)
        return sum(length.(ionss)) / sum(length.(peps))
    end
end

calc_ion(df, M2, engine) = begin
    if engine == :pFind
        return calc_ion_pfind(df, M2)
    elseif engine == :pLink
        return calc_ion_plink(df, M2)
    end
end

check_cluster_overlap!(df, V=Global_V) = begin
    df.overlap .= false
    for g in DataFrames.groupby(df, [:file, :scan])
        for a in eachrow(g)
            mzs = UniMZ.ipv_mz(UniMZ.mh_to_mz(a.mh, a.z), a.z, V)
            for b in eachrow(g)
                a === b && continue
                mzs_ = UniMZ.ipv_mz(UniMZ.mh_to_mz(b.mh, b.z), b.z, V)
                if any(UniMZ.in_moe(mz, mz_, 10e-6) for mz in mzs for mz_ in mzs_)
                    a.overlap = true
                end
            end
        end
    end
end

check_center(df, M, ε=20e-6, V=Global_V) = begin
    map(eachrow(df)) do r
        any(mz -> UniMZ.in_moe(mz, M[r.file][r.scan].activation_center, ε), UniMZ.ipv_mz(r, V))
    end
end

check_inside(df, M) = begin
    map(eachrow(df)) do r
        abs(r.mz - M[r.file][r.scan].activation_center) <= M[r.file][r.scan].isolation_width / 2
    end
end

read_n_spec(path, engine) = begin
    if engine == :pFind
        return countlines(joinpath(path, "pFind", "pFind.spectra")) - 1
    elseif engine == :pLink
        return pLink.parse_n_spec(joinpath(path, "pLink", "reports", "example.summary.txt"))
    end
end

read_n_id_spec(path, engine) = begin
    if engine == :pFind
        return countlines(joinpath(path, "pFind", "pFind-Filtered.spectra")) - 1
    elseif engine == :pLink
        return countlines(joinpath(path, "pLink", "reports", "example.filtered_cross-linked_spectra.csv")) - 1
    end
end

read_psm(path, engine) = begin
    if engine == :pFind
        return pFind.read_psm(joinpath(path, "pFind", "pFind-Filtered.spectra"))
    elseif engine == :pLink
        return pLink.read_psm(joinpath(path, "pLink", "reports", "example.filtered_cross-linked_spectra.csv"))
    end
end

bar_text(ns) = map(ns) do n
    (@sprintf("%d\n%.2f%%", n, n / sum(ns) * 100), 8, (n > 7/8 * maximum(ns) ? :vcenter : :bottom))
end

int_tick(ns) = (:)(extrema(ns)...)

plot_number!(p, x, y, label; xlabel="fold (#ion / #scan)", ylabel="#PSM", markershape=:auto, lim=4, legend=:bottomright, fold=nothing) = begin
    if length(x) == 1
        Plots.plot!(p, x, y; label, st=:scatter, marker=(markershape, Plots.stroke(0), 6),
            text=(x[begin] > lim) ? Plots.text(@sprintf("\n%.1f-fold", fold[begin]), 6, :top) : nothing,
        )
    else
        Plots.plot!(p, x, y; label, marker=(markershape, Plots.stroke(0), 4))
    end
    Plots.plot!(p; xlabel, ylabel, legend, yformatter=:plain, ylim=(0, Inf), widen=true, legend_font_pointsize=6)
    return p
end

plot_error!(p, x, label, pos_error, i;
    xlabel="measured - calculated mass (ppm)", ylabel="frequency of PSM",
) = begin
    SPlots.density!(p, x; label, xlabel, ylabel)
    vspace = "\n\n\n" ^ i * "\n" ^ 10
    text = @sprintf("%s:\n  mean=%.2f, std=%.2f%s", label, mean(x), std(x), vspace)
    Plots.annotate!(pos_error, 0, (text, 10, :left, :bottom))
    return p
end

plot_delta_mz_density!(p, x, r, label; xlabel="mono. m/z - activation center (Th)", ylabel="frequency of PSM") = begin
    SPlots.density!(p, x; label, xlabel, ylabel)
    Plots.vline!(p, [-r, r]; ls=:dash, lc=:red, label="window")
    return p
end

plot_delta_mz!(p, x, r, label; xlabel="mono. m/z - activation center (Th)", ylabel="frequency of PSM") = begin
    Plots.histogram!(p, x; label, xlabel, ylabel, grid=:y, line=0)
    Plots.vline!(p, [-r, r]; ls=:dash, lc=:red, label="window")
    return p
end

plot_mass!(p, x, label; xlabel="mass (Da)", ylabel="#PSM") = begin
    Plots.histogram!(p, x; label, xlabel, ylabel, grid=:y, fill=0.5, line=0)
    return p
end

plot_charge!(p, df, label; xlabel="charge state", ylabel="#PSM") = begin
    df = DataFrames.combine(DataFrames.groupby(df, [:z]), DataFrames.nrow)
    Plots.bar!(p, df.z, df.nrow; label, xlabel, ylabel, text=bar_text(df.nrow),
        xformatter=x -> "$(Int(x))+", yformatter=:plain, xtick=int_tick(df.z), grid=:y, line=0,
    )
    return p
end

plot_mixture!(p, df, label; xlabel="#PSM", ylabel="#scan") = begin
    df = DataFrames.combine(DataFrames.groupby(df, [:file, :scan]), DataFrames.nrow)
    df = DataFrames.combine(DataFrames.groupby(df, [:nrow]), DataFrames.nrow => :nnrow)
    Plots.bar!(p, df.nrow, df.nnrow; label, xlabel, ylabel, text=bar_text(df.nnrow),
        yformatter=:plain, xtick=int_tick(df.nrow), grid=:y, line=0,
    )
    return p
end

plot_overlap_pie!(p, x, label) = begin
    s, o = length(x) - sum(x), sum(x)
    Plots.pie!(p, ["standalone ($(s))", "overlapped ($(o))"], [s, o]; legend_title=label)
    return p
end

plot_window!(p, x, label, ws_inst, ws_algo, clim;
    xlabel="window size (instrument)", ylabel="window size (algorithm)",
) = begin
    Plots.heatmap!(p, ws_inst, ws_algo, x;
        title=label, xaxis=(xlabel, ws_inst), yaxis=(ylabel, ws_algo),
        framestyle=:box, grid=:none, tick_direction=:none, c=:cividis, cbar=:none, clim,
    )
    for (i_inst, pos_x) in enumerate(Plots.xticks(p)[1][1])
        for (i_algo, pos_y) in enumerate(Plots.yticks(p)[1][1])
            Plots.annotate!(pos_x, pos_y, (string(x[i_algo, i_inst]), :white, 8))
        end
    end
    return p
end

plot_overlap!(p, x, y, y_f, label; xlabel="fold (#ion / #scan)", ylabel="#PSM") = begin
    Plots.plot!(p, x, [y y_f];
        fillrange=[y_f zeros(size(x))], legend_title=label, label=["true" "false"],
        xlabel, ylabel, yformatter=:plain,
    )
    fdr = y_f[end] / y[end] * 100
    Plots.annotate!((x[end], y[end] / 2, (@sprintf("FDR=%.2f%% ⟶", fdr), 10, :right, :bottom)))
    return p
end

plot_basic_pre() = begin
    p_error = Plots.plot()
    p_mass = Plots.plot()
    ps_charge = map(_ -> Plots.plot(), tasks)
    ps_mixture = map(_ -> Plots.plot(), tasks)
    ps_overlap = map(_ -> Plots.plot(), tasks)
    return p_error, p_mass, ps_charge, ps_mixture, ps_overlap
end

plot_basic(df, label, idx, pos_error, p_error, p_mass, ps_charge, ps_mixture, ps_overlap) = begin
    plot_error!(p_error, df.error, label, pos_error, length(ps_charge) - idx)
    plot_mass!(p_mass, df.mh, label)
    plot_charge!(ps_charge[idx], df, label)
    plot_mixture!(ps_mixture[idx], df, label)
    plot_overlap_pie!(ps_overlap[idx], df.overlap, label)
end

plot_basic_post(path, p_error, p_mass, ps_charge, ps_mixture, ps_overlap) = begin
    Plots.savefig(p_error, "$(path)error.pdf")
    Plots.savefig(p_mass, "$(path)mass.pdf")
    p_charge = Plots.plot(ps_charge...; layout=Plots.grid(length(ps_charge), 1), link=:all)
    Plots.savefig(p_charge, "$(path)charge.pdf")
    p_mixture = Plots.plot(ps_mixture...; layout=Plots.grid(length(ps_mixture), 1), link=:all)
    Plots.savefig(p_mixture, "$(path)mixture.pdf")
    p_overlap = Plots.plot(ps_overlap...; layout=length(ps_overlap))
    Plots.savefig(p_overlap, "$(path)overlap_pie.pdf")
end
