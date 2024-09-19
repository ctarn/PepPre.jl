include("util.jl")

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@2", :run => 4.0),
            Dict(:id => "pParse@2", :run => -0.7),
            Dict(:id => "EnumEx", :run => 1),
            Dict(:id => "EnumIW", :run => 1),
            Dict(:id => "EnumInst", :run => 4),
        ],
    ),
    :ZH8 => Dict(
        :id => "Zubarev-Human-8",
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@8", :run => 4.0),
            Dict(:id => "pParse@8", :run => 0.2),
            Dict(:id => "EnumEx", :run => 1),
            Dict(:id => "EnumIW", :run => 1),
            Dict(:id => "EnumInst", :run => 4),
        ],
    ),
    :DD => Dict(
        :id => "Dong-DSS-1.6",
        :engine => :pLink,
        :tasks => [
            Dict(:id => "PepPre", :run => 4.0),
            Dict(:id => "pParse", :run => -0.8),
            Dict(:id => "EnumEx", :run => 1),
            Dict(:id => "EnumIW", :run => 1),
            Dict(:id => "EnumInst", :run => 4),
        ],
    ),
)

for d in [D[:ZH2], D[:ZH8], D[:DD]]
    d[:n_scan] = UniMZ.count_msx(joinpath(ROOT, "data", d[:id], ""), ".ms2")
    for t in d[:tasks]
        path = joinpath(ROOT, "out", d[:id], t[:id], string(t[:run]))
        n_spec = read_n_spec(path, d[:engine])
        fold = n_spec / d[:n_scan]
        println("$(path)\t=> $(fold)")
        df = read_psm(path, d[:engine])
        t[:n_spec] = n_spec
        t[:label] = split(t[:id], '@')[begin]
        t[:z] = df.z
        t[:m] = df.mh .- UniMZ.mₚ
    end
end

ms = [
    ("[0, 1.5)", x -> 0 <= x < 1500)
    ("[1.5, 2)", x -> 1500 <= x < 2000)
    ("[2, 2.5)", x -> 2000 <= x < 2500)
    ("[2.5, 3)", x -> 2500 <= x < 3000)
    ("[3, \$\\infty\$)", x -> 3000 <= x)
]

fig = plt.figure(figsize=(12, 6))
gs = fig.add_gridspec(2, 3)
width = 0.15
Δ = -2:2 |> collect
for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
    ax = fig.add_subplot(gs[1, i])
    ax.set_title(d[:id])
    xs = 2:6 |> collect
    ys = [[sum(t[:z] .== z) for z in xs] for t in d[:tasks]]
    @info xs, ys
    for (i, t) in enumerate(d[:tasks])
        ax.bar(xs .+ Δ[i] * width, ys[i], width, label=t[:label])
    end
    ax.set_xlabel("charge state")
    ax.set_ylabel("#PSM")
    ax.set_xticks(xs, ["\$$(x)+\$" for x in xs])
    Plot.draw_index!(ax, "$('a' - 1 + i)1."; x=-0.15, y=1.05, hide_axis=false)
    ax.legend()

    ax = fig.add_subplot(gs[2, i])
    xs = ms |> eachindex |> collect
    ys = [[sum(f.(t[:m])) for (_, f) in ms] for t in d[:tasks]]
    @info xs, ys
    for (i, t) in enumerate(d[:tasks])
        ax.bar(xs .+ Δ[i] * width, ys[i], width, label=t[:label])
    end
    ax.set_xlabel("mass (kDa)")
    ax.set_ylabel("#PSM")
    ax.set_xticks(xs, [l for (l, _) in ms])
    Plot.draw_index!(ax, "$('a' - 1 + i)2."; x=-0.15, y=1.05, hide_axis=false)
    ax.legend()
end

fig.tight_layout()
fig.subplots_adjust(hspace=0.25)
fig.savefig(joinpath(ROOT, "fig", "PepPre_dist.pdf"))
plt.close(fig)
