include("util.jl")

ROOT_REMOTE = "/Volumes/ctarn/PepPre/"

D = Dict(
    :id => "Zubarev-Human-2",
    :engine => :pFind,
    :tasks => [
        Dict(:id => "PepPre@t0.0", :label => "\$\\tau = 0.0\$", :runs => 1:0.2:4),
        Dict(:id => "PepPre@t0.1", :label => "\$\\tau = 0.1\$", :runs => 1:0.2:4),
        Dict(:id => "PepPre@t0.5", :label => "\$\\tau = 0.5\$", :runs => 1:0.2:4),
        Dict(:id => "PepPre@t1.0", :label => "\$\\tau = 1.0\$", :runs => 1:0.2:4),
        Dict(:id => "PepPre@t2.0", :label => "\$\\tau = 2.0\$", :runs => 1:0.2:4),
    ],
)

D[:n_scan] = UniMZ.count_msx(joinpath(ROOT, "data", D[:id], ""), ".ms2")
for t in D[:tasks]
    t[:n_spec] = []
    t[:n_id_spec] = []
    t[:n_id_pep] = []
    for run in t[:runs]
        path = joinpath(ROOT_REMOTE, "out", D[:id], t[:id], string(run))
        df = read_psm(path, :pFind)
        push!(t[:n_spec], read_n_spec(path, :pFind))
        push!(t[:n_id_spec], size(df, 1))
        push!(t[:n_id_pep], size(unique(df, [:pep, :mod]), 1))
        @info "fold=$(t[:n_spec][end] / D[:n_scan])\t#id. spec=$(t[:n_id_spec][end])\t#id. pep=$(t[:n_id_pep][end])"
    end
end

fig = plt.figure(figsize=(12, 4))
gs = fig.add_gridspec(1, 2)
D[:ax_psm] = fig.add_subplot(gs[1, 1])
D[:ax_pep] = fig.add_subplot(gs[1, 2])

for t in D[:tasks]
    x = t[:n_spec] ./ D[:n_scan]
    D[:ax_psm].plot(x, t[:n_id_spec]; label=t[:label])
    D[:ax_pep].plot(x, t[:n_id_pep]; label=t[:label])
end

for ax in [D[:ax_psm], D[:ax_pep]]
    ax.set_xticks(1:4, ["\$$(x)\\times\$" for x in 1:4])
    ax.set_xlabel("fold (#ion / #scan)")
    ax.legend()
end

D[:ax_psm].set_ylabel("#PSM")
D[:ax_pep].set_ylabel("#peptide")
Plot.draw_index!(D[:ax_psm], "a."; x=-0.15, y=1.02, hide_axis=false)
Plot.draw_index!(D[:ax_pep], "b."; x=-0.15, y=1.02, hide_axis=false)

fig.tight_layout()
fig.savefig(joinpath(ROOT, "fig", "PepPre_optim_t.pdf"))
plt.close(fig)
