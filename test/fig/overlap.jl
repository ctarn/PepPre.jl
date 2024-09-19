include("util.jl")

D = Dict(
    :id => "Dong-DSS-1.6",
    :fasta=>"dong-syn.fasta",
    :tasks => [
        Dict(:id => "PepPre", :runs => 1:0.2:4),
        Dict(:id => "pParse", :runs => 1:-0.1:-1),
    ],
)

fasta = UniMZ.read_fasta(joinpath(ROOT, "fasta", D[:fasta]))
D[:n_scan] = UniMZ.count_msx(joinpath(ROOT, "data", D[:id], ""), ".ms2")
for t in D[:tasks]
    t[:n_spec] = Int[]
    t[:n_id_spec] = Int[]
    t[:n_spec_overlap] = Int[]
    t[:n_spec_overlap_f] = Int[]
    for run in t[:runs]
        path = joinpath(ROOT, "out", D[:id], t[:id], string(run))
        df = read_psm(path, :pLink)
        df.ist = check_prot([df.prot_a, df.prot_b], getfield.(fasta, :id))
        check_cluster_overlap!(df)
        push!(t[:n_spec], read_n_spec(path, :pLink))
        push!(t[:n_id_spec], size(df, 1))
        push!(t[:n_spec_overlap], sum(df.overlap))
        push!(t[:n_spec_overlap_f], sum(df.overlap .& .!df.ist))
        println("fold=$(t[:n_spec][end] / D[:n_scan]):\t$(t[:n_spec_overlap_f][end])/$(t[:n_spec_overlap][end])\t$(t[:n_id_spec][end])")
    end
end

n_tasks = length(D[:tasks])
fig = plt.figure(figsize=(6, 2.5 * n_tasks))
gs = fig.add_gridspec(n_tasks, 1)
for (i, t) in enumerate(D[:tasks])
    ax = fig.add_subplot(gs[i, 1])
    xs = t[:n_spec] ./ D[:n_scan]
    ax.fill_between(xs, t[:n_spec_overlap], t[:n_spec_overlap_f], label="true", color="skyblue")
    ax.fill_between(xs, t[:n_spec_overlap_f], label="false", color="lightcoral")
    ax.annotate(
        @sprintf("FDR=%.2f%%", t[:n_spec_overlap_f][end] / t[:n_spec_overlap][end] * 100),
        (xs[end], t[:n_spec_overlap][end]/2),
        xytext=(xs[end]-0.2, t[:n_spec_overlap][end]/2), ha="right", va="center",
        arrowprops=Dict([:arrowstyle=>"->", :color=>"black"]),
    )
    ax.set_xlabel("fold (#ion / #scan)")
    ax.set_ylabel("#PSM")
    ax.set_xticks(1:5, ["\$$(x)\\times\$" for x in 1:5])
    ax.legend(title=t[:id])
end
fig.axes[begin].sharex(fig.axes[end])
fig.axes[end].sharey(fig.axes[begin])

fig.tight_layout()

for i in eachindex(D[:tasks])
    Plot.draw_index!(fig.add_subplot(gs[i, 1]), "$('a' + i - 1)."; x=-0.1, y=0.95)
end

fig.savefig(joinpath(ROOT, "fig", "PepPre_overlap.pdf"))
plt.close(fig)
