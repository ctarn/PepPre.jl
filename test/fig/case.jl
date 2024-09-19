include("util.jl")

ε = 20e-6

load_psm_pre(df) = begin
    P = Dict{Tuple{String, Int}, Vector}()
    for r in eachrow(df)
        push!(get!(P, (r.file, r.scan), []), r)
    end
    return P
end

path_ms = joinpath(ROOT, "data", "Zubarev-Human-8", "")
path_psm = joinpath(ROOT, "out", "Zubarev-Human-8", "PepPre@8", "4.0", "pFind", "pFind-Filtered.spectra")
path_mgf = joinpath(ROOT, "out", "Zubarev-Human-8", "PepPre@8", "4.0", "20131202_hela1_120min_8MZ.mgf.csv")

M1 = UniMZ.read_all(UniMZ.read_ms1, path_ms, ".ms1") |> UniMZ.mapvalue(UniMZ.dict_by_id)
M2 = UniMZ.read_all(UniMZ.read_ms2, path_ms, ".ms2") |> UniMZ.mapvalue(UniMZ.dict_by_id)

df_psm = UniMZUtil.pFind.read_psm(path_psm)
dc_psm = load_psm_pre(df_psm)
for v in values(dc_psm)
    sort!(v; by=x -> x.mz)
end

df_ion = [(; file=k[1], scan=k[2], n=length(v), v) for (k, v) in dc_psm] |> DataFrames.DataFrame
sort!(df_ion, :n; rev=true)

colors = plt.rcParams["axes.prop_cycle"].by_key()["color"][2:end]

tab_ele = pFind.read_element() |> NamedTuple
tab_aa = map(x -> UniMZ.mass(x, tab_ele), pFind.read_amino_acid() |> NamedTuple)
tab_mod = map(x -> x.mass, pFind.read_modification() |> NamedTuple)

for (idx_r, r) in enumerate(eachrow(df_ion)[1:4])
    ms2 = M2[r.file][r.scan]
    ms1 = M1[r.file][ms2.pre]

    fig = plt.figure(figsize=(8, 6))
    gs = fig.add_gridspec(2, 1; height_ratios=[3, 1])
    ax = fig.add_subplot(gs[1, 1])
    ax.set_title("File: $(r.file), MS1: $(ms1.id), MS2: $(ms2.id)")

    peaks = UniMZ.query_δ(ms1.peaks, ms2.activation_center, ms2.isolation_width / 2 + 4)
    f = Int(floor(log10(maximum(x -> x.inten, peaks))))
    ax.vlines(ms2.activation_center .+ [-1/2, 1/2] .* ms2.isolation_width, 0.8, 1.2; linestyle="dashed", color="blue")
    xs = [p.mz for p in peaks]
    ys = [p.inten for p in peaks] ./ 10^f
    ax.vlines(xs, 0, ys; linewidth=1)
    ax.text(ms2.activation_center, 1, "\$\\Longleftarrow\$ isolation window \$\\Longrightarrow\$"; color="blue", fontweight="bold", ha="center")

    for (idx, i) in enumerate(dc_psm[(r.file, r.scan)])
        color = colors[(idx-1)%length(colors)+1]
        w = UniMZ.max_inten_ε(peaks, i.mz, ε/4)
        xs, ys = UniMZ.ipv_mz(i, Global_V), UniMZ.ipv_w(i, Global_V)
        ys = - ys .* (w / ys[1]) ./ 10^f
        for (x, y) in zip(xs, ys)
            ax.vlines(x, 0, y; color, linewidth=1)
        end
        ax.text(xs[begin], ys[begin], string(idx); fontweight="bold", color, va="top", ha="left")
    end

    ax.set_xlabel("m/z (Th)")
    ax.set_ylabel("intensity (\$\\times 10^{$(f)}\$)")
    ax.set_yticks(ax.get_yticks(), string.(abs.(ax.get_yticks())))

    ax_tab = fig.add_subplot(gs[2, 1])
    ax_tab.axis("off")
    labels = ["m/z (Th)", "charge state", "sequence", "modification", "q-value"]
    ax_tab.table(
        cellText=[
            [@sprintf("%.6f", r.mz), r.z, r.pep, r.mod, @sprintf("%.2f%%", r.fdr*100)]
            for r in dc_psm[(r.file, r.scan)]
        ],
        rowColours=map(i -> colors[(i-1)%length(colors)+1], eachindex(dc_psm[(r.file, r.scan)])),
        rowLabels=["#$(i) ion" for i in eachindex(dc_psm[(r.file, r.scan)])],
        colLabels=labels, loc="upper center", cellLoc="center",
    )

    fig.tight_layout()
    fig.savefig(joinpath(ROOT, "fig", "PepPre_case_$(idx_r).pdf"))
    plt.close(fig)

    for (idx_psm, psm) in enumerate(dc_psm[(r.file, r.scan)])
        ions = UniMZ.build_ions(ms2.peaks, psm.pep, psm.mod, ε, tab_ele, tab_aa, tab_mod)

        fig = plt.figure(figsize=(8, 6))
        gs = fig.add_gridspec(3, 1; height_ratios=[1, 3, 1])
        ax_seq = Plot.seq!(fig.add_subplot(gs[1, 1]), psm.pep, psm.mod, ions)
        ax_spec = Plot.spec!(fig.add_subplot(gs[2, 1]), ms2.peaks, ions)
        ax_error = Plot.error!(fig.add_subplot(gs[3, 1]), ions, ε; x=:mz_exp)
        ax_spec.set_xlabel("")
        ax_error.sharex(ax_spec)
        ax_error.tick_params(bottom=false, labelbottom=false, top=true)

        fig.tight_layout()
        fig.subplots_adjust(hspace=0.2)
        fig.savefig(joinpath(ROOT, "fig", "PepPre_case_$(idx_r)_$(idx_psm).pdf"))
        plt.close(fig)
    end
end
