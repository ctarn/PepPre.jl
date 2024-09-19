include("util.jl")

ROOT_REMOTE = "/Volumes/ctarn/PepPre/"

D = [
    Dict(
        :id => "Bruderer-Human-DIA30k",
        :label => "30k",
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@5ppm", :runs => 1:0.2:8, :label => "5ppm", :linestyle => "dotted"),
            Dict(:id => "PepPre", :runs => 1:0.2:8, :label => "10ppm", :linestyle => "dashed"),
            Dict(:id => "PepPre@20ppm", :runs => 1:0.2:8, :label => "20ppm", :linestyle => "solid"),
        ]
    ),
    Dict(
        :id => "Bruderer-Human-DIA60k",
        :label => "60k",
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@5ppm", :runs => 1:0.2:8, :label => "5ppm", :linestyle => "dotted"),
            Dict(:id => "PepPre", :runs => 1:0.2:8, :label => "10ppm", :linestyle => "dashed"),
            Dict(:id => "PepPre@20ppm", :runs => 1:0.2:8, :label => "20ppm", :linestyle => "solid"),
        ]
    ),
    Dict(
        :id => "Bruderer-Human-DIA120k",
        :label => "120k",
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@5ppm", :runs => 1:0.2:8, :label => "5ppm", :linestyle => "dotted"),
            Dict(:id => "PepPre", :runs => 1:0.2:8, :label => "10ppm", :linestyle => "dashed"),
            Dict(:id => "PepPre@20ppm", :runs => 1:0.2:8, :label => "20ppm", :linestyle => "solid"),
        ]
    ),
    Dict(
        :id => "Bruderer-Human-DIA240k",
        :label => "240k",
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@5ppm", :runs => 1:0.2:8, :label => "5ppm", :linestyle => "dotted"),
            Dict(:id => "PepPre", :runs => 1:0.2:8, :label => "10ppm", :linestyle => "dashed"),
            Dict(:id => "PepPre@20ppm", :runs => 1:0.2:8, :label => "20ppm", :linestyle => "solid"),
        ]
    ),
]

for d in D
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

fig = plt.figure(figsize=(12, 4))
gs = fig.add_gridspec(1, 2)
ax_psm = fig.add_subplot(gs[1, 1])
ax_pep = fig.add_subplot(gs[1, 2])

colors = plt.rcParams["axes.prop_cycle"].by_key()["color"]
for (d, c) in zip(D, colors)
    for t in d[:tasks]
        x = t[:n_spec] ./ d[:n_scan]
        ax_psm.plot(x, t[:n_id_spec]; label="$(d[:label]), $(t[:label])", linestyle=t[:linestyle], color=c)
        ax_pep.plot(x, t[:n_id_pep]; label="$(d[:label]), $(t[:label])", linestyle=t[:linestyle], color=c)
    end
end

for ax in [ax_psm, ax_pep]
    ax.set_xticks(1:8, ["\$$(x)\\times\$" for x in 1:8])
    ax.set_xlabel("fold (#ion / #scan)")
    ax.set_ylim(bottom=0)
    ax.legend(title="MS1 Resolution, MS1 Mass Error", loc="lower right", ncol=2)
end

ax_psm.set_ylabel("#PSM")
ax_pep.set_ylabel("#peptide")
Plot.draw_index!(ax_psm, "a."; x=-0.15, y=1.02, hide_axis=false)
Plot.draw_index!(ax_pep, "b."; x=-0.15, y=1.02, hide_axis=false)

fig.tight_layout()
fig.savefig(joinpath(ROOT, "fig", "PepPre_number_DIA.pdf"))
plt.close(fig)
