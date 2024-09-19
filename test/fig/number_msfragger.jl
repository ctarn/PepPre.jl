include("util.jl")

markers = Dict(
    "PepPre" => ".",
    "With Correction" => ".",
    "Without Correction" => ".",
)

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :engine => :MSFragger,
        :tasks => [
            Dict(:id => "PepPre@2", :label => "PepPre", :dir => "MSFragger", :runs => 1:0.2:4, :color => missing),
            Dict(:id => "EnumInst", :label => "With Correction", :dir => "MSFraggerIso", :runs => 1:1, :color => "seagreen"),
            Dict(:id => "EnumInst", :label => "Without Correction", :dir => "MSFragger", :runs => 1:1, :color => "steelblue"),
        ],
    ),
    :ZH8 => Dict(
        :id => "Zubarev-Human-8",
        :engine => :MSFragger,
        :tasks => [
            Dict(:id => "PepPre@8", :label => "PepPre", :dir => "MSFragger", :runs => 1:0.2:3.2, :color => missing),
            Dict(:id => "EnumInst", :label => "With Correction", :dir => "MSFraggerIso", :runs => 1:1, :color => "seagreen"),
            Dict(:id => "EnumInst", :label => "Without Correction", :dir => "MSFragger", :runs => 1:1, :color => "steelblue"),
        ],
    ),
)

for d in [D[:ZH2], D[:ZH8]]
    d[:n_scan] = UniMZ.count_msx(joinpath(ROOT, "data", d[:id], ""), ".ms2")
    for t in d[:tasks]
        t[:n_spec] = []
        t[:n_id_spec] = []
        t[:n_id_pep] = []
        for run in t[:runs]
            path = joinpath(ROOT, "out", d[:id], t[:id], string(run))
            push!(t[:n_spec], read_n_spec(path, :MSFragger))
            df = read_psm_msfragger(joinpath(path, t[:dir], "psm.tsv"))
            push!(t[:n_id_spec], size(df, 1))
            df = read_pep_msfragger(joinpath(path, t[:dir], "peptide.tsv"))
            push!(t[:n_id_pep], size(df, 1))
            @info "fold=$(t[:n_spec][end] / d[:n_scan])\t#id. spec=$(t[:n_id_spec][end])\t#id. pep=$(t[:n_id_pep][end])"
        end
    end
end

plot(ax, x, y, label, color=missing) = begin
    if length(x) > 1
        ax.plot(x, y; label, marker=markers[label])
    else
        ax.hlines(only(y), 1, 4; label, linestyles="dashed", color)
    end
end

fig = plt.figure(figsize=(8, 6))
gs = fig.add_gridspec(2, 2)
for (i, d) in enumerate([D[:ZH2], D[:ZH8]])
    d[:ax_psm] = fig.add_subplot(gs[1, i])
    d[:ax_pep] = fig.add_subplot(gs[2, i])
    d[:ax_psm].set_title(d[:id])

    for t in d[:tasks]
        x = t[:n_spec] ./ d[:n_scan]
        plot(d[:ax_psm], x, t[:n_id_spec], t[:label], t[:color])
        plot(d[:ax_pep], x, t[:n_id_pep], t[:label], t[:color])
    end

    d[:ax_pep].sharex(d[:ax_psm])

    d[:ax_psm].set_ylabel("#PSM")
    d[:ax_pep].set_ylabel("#peptide")

    for (j, ax) in enumerate([d[:ax_psm], d[:ax_pep]])
        ax.set_xticks(1:4, ["\$$(x)\\times\$" for x in 1:4])
        ax.set_xlabel("fold (#ion / #scan)")
        ax.set_ylim(bottom=0)
        UniMZ.Plot.draw_index!(ax, "$('a' + i - 1)$(j)."; x=-0.15, y=1.04, hide_axis=false)
    end
end

D[:ZH2][:ax_pep].legend(; loc="lower left")

fig.tight_layout()
fig.subplots_adjust(hspace=0.2, wspace=0.25)
fig.savefig(joinpath(ROOT, "fig", "PepPre_number_MSFragger.pdf"))
plt.close(fig)
