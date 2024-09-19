include("util.jl")

markers = Dict(
    "PepPre" => ".",
    "pParse" => ".",
    "RawConverter" => "D",
    "Monocle" => "H",
    "Decon2LS" => "o",
    "RAPID" => "h",
    "MaxQuant" => "s",
    "Dinosaur" => "P",
    "PointIso" => "X",
    "EnumInst" => ".",
    "EnumIW" => "*",
    "EnumEx" => "*",
)

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@2", :runs => 1:0.2:4),
            Dict(:id => "pParse@2", :runs => 1:-0.1:-0.8),
            Dict(:id => "RawConverter", :runs => 1:1),
            Dict(:id => "Monocle", :runs => 1:1),
            Dict(:id => "Decon2LS", :runs => 1:1),
            Dict(:id => "RAPID", :runs => 1:1),
            Dict(:id => "MaxQuant", :runs => 1:1),
            Dict(:id => "Dinosaur", :runs => 1:1),
            Dict(:id => "PointIso", :runs => 1:1),
            Dict(:id => "EnumInst", :runs => 1:4),
            Dict(:id => "EnumIW", :runs => 1:1, :ha => "right"),
            Dict(:id => "EnumEx", :runs => 1:1, :ha => "left"),
        ],
        :psm_inset => [0.4, 0.05, 0.2, 0.2],
        :psm_inset_xlim => (0.9, 1.2),
        :psm_inset_ylim => (36000, 44000),
    ),
    :ZH8 => Dict(
        :id => "Zubarev-Human-8",
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@8", :runs => 1:0.2:4),
            Dict(:id => "pParse@8", :runs => 1:-0.1:0.2),
            Dict(:id => "RawConverter", :runs => 1:1),
            Dict(:id => "Monocle", :runs => 1:1),
            Dict(:id => "Decon2LS", :runs => 1:1),
            Dict(:id => "RAPID", :runs => 1:1, :ha => "right"),
            Dict(:id => "MaxQuant", :runs => 1:1),
            Dict(:id => "Dinosaur", :runs => 1:1, :ha => "right"),
            Dict(:id => "PointIso", :runs => 1:1),
            Dict(:id => "EnumInst", :runs => 1:4),
            Dict(:id => "EnumIW", :runs => 1:1, :ha => "right"),
            Dict(:id => "EnumEx", :runs => 1:1, :ha => "left"),
        ],
        :psm_inset => [0.4, 0.05, 0.2, 0.2],
        :psm_inset_xlim => (0.9, 1.2),
        :psm_inset_ylim => (35000, 45000),
    ),
)

for d in [D[:ZH2], D[:ZH8]]
    d[:n_scan] = UniMZ.count_msx(joinpath(ROOT, "data", d[:id], ""), ".ms2")
    for t in d[:tasks]
        t[:label] = split(t[:id], '@')[begin]
        t[:n_spec] = []
        t[:n_id_spec] = []
        t[:n_id_pep] = []
        t[:n_id_prot_grp] = []
        t[:cov_id_prot_grp] = []
        for run in t[:runs]
            path = joinpath(ROOT, "out", d[:id], t[:id], string(run))
            df = read_psm(path, :pFind)
            lines = joinpath(path, "pFind", "pFind.protein") |> readlines
            push!(t[:n_spec], read_n_spec(path, :pFind))
            push!(t[:n_id_spec], size(df, 1))
            push!(t[:n_id_pep], size(unique(df, [:pep, :mod]), 1))
            push!(t[:n_id_prot_grp], parse(Int, split(lines[end-1])[2]))
            push!(t[:cov_id_prot_grp], parse(Float64, split(lines[end])[2][1:end-1]))
            @info "fold=$(t[:n_spec][end] / d[:n_scan])\t#id. spec=$(t[:n_id_spec][end])\t#id. pep=$(t[:n_id_pep][end])\t#id. prot group=$(t[:n_id_prot_grp][end])\tcoverage=$(t[:cov_id_prot_grp][end])"
        end
    end
end

plot(ax, x, y, label, ha) = begin
    if length(x) > 1
        ax.plot(x, y; label, marker=markers[label])
    else
        x, y = x[begin], y[begin]
        x_ = x > 4 ? 4 + log((x - 4) + 1) / 2 : x
        ax.scatter(x_, y; label, marker=markers[label], linewidths=0.0)
        if x > 4
            ax.text(x_, y, @sprintf("\n\n\$%.1f \\times\$", x), ha=ha, va="center", fontsize=8)
        end
    end
end

fig = plt.figure(figsize=(12, 12))
gs = fig.add_gridspec(4, 2)
for (i, d) in enumerate([D[:ZH2], D[:ZH8]])
    d[:ax_psm] = fig.add_subplot(gs[1, i])
    d[:ax_pep] = fig.add_subplot(gs[2, i])
    d[:ax_prot] = fig.add_subplot(gs[3, i])
    d[:ax_prot_cov] = fig.add_subplot(gs[4, i])
    d[:ax_psm].set_title(d[:id])

    for t in d[:tasks]
        x = t[:n_spec] ./ d[:n_scan]
        plot(d[:ax_psm], x, t[:n_id_spec], t[:label], get(t, :ha, "center"))
        plot(d[:ax_pep], x, t[:n_id_pep], t[:label], get(t, :ha, "center"))
        plot(d[:ax_prot], x, t[:n_id_prot_grp], t[:label], get(t, :ha, "center"))
        plot(d[:ax_prot_cov], x, t[:cov_id_prot_grp], t[:label], get(t, :ha, "center"))
    end

    d[:ax_pep].sharex(d[:ax_psm])
    d[:ax_prot].sharex(d[:ax_psm])
    d[:ax_prot_cov].sharex(d[:ax_psm])

    d[:ax_psm].set_ylabel("#PSM")
    d[:ax_pep].set_ylabel("#peptide")
    d[:ax_prot].set_ylabel("#protein group")
    d[:ax_prot_cov].set_ylabel("protein group coverage (%)")

    for (j, ax) in enumerate([d[:ax_psm], d[:ax_pep], d[:ax_prot], d[:ax_prot_cov]])
        ax.set_xticks(1:4, ["\$$(x)\\times\$" for x in 1:4])
        ax.set_xlabel("fold (#ion / #scan)")
        UniMZ.Plot.draw_index!(ax, "$('a' + i - 1)$(j)."; x=-0.1, y=1.0, hide_axis=false)
    end
end

D[:ZH2][:ax_prot_cov].legend(ncol=2)

fig.tight_layout()
fig.subplots_adjust(hspace=0.2, wspace=0.18)
fig.savefig(joinpath(ROOT, "fig", "PepPre_number_prot.pdf"))
plt.close(fig)
