include("util.jl")

markers = Dict(
    "PepPre" => ".",
    "PepPre+" => ".",
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
            Dict(:id => "PepPre+@2", :runs => 1:0.2:4),
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
            Dict(:id => "PepPre+@8", :runs => 1:0.2:4),
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
    :DD => Dict(
        :id => "Dong-DSS-1.6",
        :engine => :pLink,
        :fasta => "dong-syn.fasta",
        :tasks => [
            Dict(:id => "PepPre", :runs => 1:0.2:4),
            Dict(:id => "PepPre+", :runs => 1:0.2:4),
            Dict(:id => "pParse", :runs => 1:-0.1:-0.8),
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
        :psm_inset => [0.4, 0.05, 0.2, 0.4],
        :psm_inset_xlim => (0.9, 1.5),
        :psm_inset_ylim => (20000, 35000),
    ),
)

for d in [D[:ZH2], D[:ZH8]]
    d[:n_scan] = UniMZ.count_msx(joinpath(ROOT, "data", d[:id], ""), ".ms2")
    for t in d[:tasks]
        t[:label] = split(t[:id], '@')[begin]
        t[:n_spec] = []
        t[:n_id_spec] = []
        t[:n_id_pep] = []
        for run in t[:runs]
            path = joinpath(ROOT, "out", d[:id], t[:id], string(run))
            df = read_psm(path, :pFind)
            push!(t[:n_spec], read_n_spec(path, :pFind))
            push!(t[:n_id_spec], size(df, 1))
            push!(t[:n_id_pep], size(unique(df, [:pep, :mod]), 1))
            @info "fold=$(t[:n_spec][end] / d[:n_scan])\t#id. spec=$(t[:n_id_spec][end])\t#id. pep=$(t[:n_id_pep][end])"
        end
    end
end

d = D[:DD]
fasta = UniMZ.read_fasta(joinpath(ROOT, "fasta", d[:fasta]))
d[:n_scan] = UniMZ.count_msx(joinpath(ROOT, "data", d[:id], ""), ".ms2")
for t in d[:tasks]
    t[:label] = split(t[:id], '@')[begin]
    t[:n_spec] = []
    t[:n_id_spec] = []
    t[:n_id_spec_t] = []
    t[:n_id_pep] = []
    t[:n_id_pep_t] = []
    for run in t[:runs]
        path = joinpath(ROOT, "out", d[:id], t[:id], string(run))
        df = read_psm(path, :pLink)
        df.ist = check_prot([df.prot_a, df.prot_b], getfield.(fasta, :id))
        push!(t[:n_spec], read_n_spec(path, :pLink))
        push!(t[:n_id_spec], size(df, 1))
        push!(t[:n_id_spec_t], sum(df.ist))
        df = unique(df, [:pep_a, :mod_a, :site_a, :pep_b, :mod_b, :site_b])
        push!(t[:n_id_pep], size(df, 1))
        push!(t[:n_id_pep_t], sum(df.ist))
        @info "fold=$(t[:n_spec][end] / d[:n_scan])\t#id. spec=$(t[:n_id_spec][end])\t#id. pep=$(t[:n_id_pep][end])"
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

fig = plt.figure(figsize=(12, 6))
gs = fig.add_gridspec(5, 3, height_ratios=(0, 2, 1, 2, 1))
for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
    Plot.draw_title!(fig.add_subplot(gs[1, i]), d[:id])
    d[:ax_psm] = fig.add_subplot(d[:engine] == :pFind ? py"$(gs)[1:3, $(i-1)]" : gs[2, i])
    d[:ax_pep] = fig.add_subplot(d[:engine] == :pFind ? py"$(gs)[3:5, $(i-1)]" : gs[4, i])
    d[:ax_psm_fdr] = d[:engine] == :pFind ? nothing : fig.add_subplot(gs[3, i])
    d[:ax_pep_fdr] = d[:engine] == :pFind ? nothing : fig.add_subplot(gs[5, i])

    for t in d[:tasks]
        x = t[:n_spec] ./ d[:n_scan]
        plot(d[:ax_psm], x, t[:n_id_spec], t[:label], get(t, :ha, "center"))
        plot(d[:ax_pep], x, t[:n_id_pep], t[:label], get(t, :ha, "center"))
        if d[:engine] != :pFind
            fdr_spec = (1 .- t[:n_id_spec_t] ./ t[:n_id_spec]) .* 100
            fdr_pep = (1 .- t[:n_id_pep_t] ./ t[:n_id_pep]) .* 100
            plot(d[:ax_psm_fdr], x, fdr_spec, t[:label], get(t, :ha, "center"))
            plot(d[:ax_pep_fdr], x, fdr_pep, t[:label], get(t, :ha, "center"))
        end
    end

    d[:ax_pep].sharex(d[:ax_psm])
    !isnothing(d[:ax_psm_fdr]) && d[:ax_psm_fdr].sharex(d[:ax_psm])
    !isnothing(d[:ax_pep_fdr]) && d[:ax_pep_fdr].sharex(d[:ax_psm])

    last_ax = isnothing(d[:ax_pep_fdr]) ? d[:ax_pep] : d[:ax_pep_fdr]
    last_ax.set_xticks(1:4, ["\$$(x)\\times\$" for x in 1:4])
    last_ax.set_xlabel("fold (#ion / #scan)")

    d[:ax_psm].tick_params(bottom=false, labelbottom=false)
    (d[:ax_pep] != last_ax) && d[:ax_pep].tick_params(bottom=false, labelbottom=false)
    !isnothing(d[:ax_psm_fdr]) && d[:ax_psm_fdr].tick_params(bottom=false, labelbottom=false)

    d[:ax_psm].set_ylabel("#PSM")
    d[:ax_pep].set_ylabel(d[:engine] == :pFind ? "#peptide" : "#peptide pair")
    !isnothing(d[:ax_psm_fdr]) && d[:ax_psm_fdr].set_ylabel("FDR (%)")
    !isnothing(d[:ax_pep_fdr]) && d[:ax_pep_fdr].set_ylabel("FDR (%)")

    d[:ax_psm].set_ylim(bottom=0)
    d[:ax_pep].set_ylim(bottom=0)
end

D[:ZH2][:ax_pep].legend(ncol=2)

fig.tight_layout()
fig.subplots_adjust(hspace=0.05, wspace=0.25)

for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
    Plot.draw_index!(fig.add_subplot(gs[2, i]), "$('a' + i - 1)."; x=-0.15, y=1.0)
    ax_psm_inset = d[:ax_psm].inset_axes(d[:psm_inset])
    for t in d[:tasks]
        x = t[:n_spec] ./ d[:n_scan]
        plot(ax_psm_inset, x, t[:n_id_spec], t[:label], get(t, :ha, "center"))
    end
    ax_psm_inset.set_xlim(d[:psm_inset_xlim]...)
    ax_psm_inset.set_ylim(d[:psm_inset_ylim]...)
    ax_psm_inset.set_xticks([])
    ax_psm_inset.set_yticks([])
    d[:ax_psm].indicate_inset_zoom(ax_psm_inset, edgecolor="black")
end

fig.savefig(joinpath(ROOT, "fig", "PepPre_number.pdf"))
plt.close(fig)
