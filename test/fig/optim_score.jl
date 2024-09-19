include("util.jl")

ROOT_REMOTE = "/Volumes/ctarn/PepPre/"

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@2", :label => "score by \$m \\times f\$", :runs => 1:0.2:4),
            Dict(:id => "PepPre-m", :label => "score by \$m\$", :runs => 1:0.2:4),
            Dict(:id => "PepPre-x", :label => "score by \$f\$", :runs => 1:0.2:4),
        ],
    ),
    :ZH8 => Dict(
        :id => "Zubarev-Human-8",
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@8", :label => "score by \$m \\times f\$", :runs => 1:0.2:4),
            Dict(:id => "PepPre-m", :label => "score by \$m\$", :runs => 1:0.2:4),
            Dict(:id => "PepPre-x", :label => "score by \$f\$", :runs => 1:0.2:4),
        ],
    ),
    :DD => Dict(
        :id => "Dong-DSS-1.6",
        :engine => :pLink,
        :fasta => "dong-syn.fasta",
        :tasks => [
            Dict(:id => "PepPre", :label => "score by \$m \\times f\$", :runs => 1:0.2:4),
            Dict(:id => "PepPre-m", :label => "score by \$m\$", :runs => 1:0.2:4),
            Dict(:id => "PepPre-x", :label => "score by \$f\$", :runs => 1:0.2:4),
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
            path = joinpath(ROOT_REMOTE, "out", d[:id], t[:id], string(run))
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
    t[:n_spec] = []
    t[:n_id_spec] = []
    t[:n_id_spec_t] = []
    t[:n_id_pep] = []
    t[:n_id_pep_t] = []
    for run in t[:runs]
        path = joinpath(ROOT_REMOTE, "out", d[:id], t[:id], string(run))
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
        d[:ax_psm].plot(x, t[:n_id_spec], label=t[:label])
        d[:ax_pep].plot(x, t[:n_id_pep], label=t[:label])
        if d[:engine] != :pFind
            fdr_spec = (1 .- t[:n_id_spec_t] ./ t[:n_id_spec]) .* 100
            fdr_pep = (1 .- t[:n_id_pep_t] ./ t[:n_id_pep]) .* 100
            d[:ax_psm_fdr].plot(x, fdr_spec, label=t[:label])
            d[:ax_pep_fdr].plot(x, fdr_pep, label=t[:label])
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
    Plot.draw_index!(fig.add_subplot(gs[2, i]), "$('a' + i - 1)."; x=-0.15, y=1.0)
end

D[:ZH2][:ax_pep].legend()

fig.tight_layout()
fig.subplots_adjust(hspace=0.05, wspace=0.25)
fig.savefig(joinpath(ROOT, "fig", "PepPre_optim_score.pdf"))
plt.close(fig)
