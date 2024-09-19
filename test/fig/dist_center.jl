include("util.jl")

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :isolation_width => 2,
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@2", :run => 4.0),
            Dict(:id => "pParse@2", :run => -0.7),
            Dict(:id => "EnumEx", :run => 1),
        ],
    ),
    :ZH8 => Dict(
        :id => "Zubarev-Human-8",
        :isolation_width => 8,
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@8", :run => 4.0),
            Dict(:id => "pParse@8", :run => 0.2),
            Dict(:id => "EnumEx", :run => 1),
        ],
    ),
    :DD => Dict(
        :id => "Dong-DSS-1.6",
        :isolation_width => 1.6,
        :engine => :pLink,
        :tasks => [
            Dict(:id => "PepPre", :run => 4.0),
            Dict(:id => "pParse", :run => -0.8),
            Dict(:id => "EnumEx", :run => 1),
        ],
    ),
)

zs = [
    ("1+", x -> x == 1)
    ("2+", x -> x == 2)
    ("3+", x -> x == 3)
    ("4+", x -> x == 4)
    ("5+", x -> x == 5)
    ("≥ 6+", x -> x >= 6)
 ]

 ms = [
    ("[0, 1.5)", x -> 0 <= x < 1500)
    ("[1.5, 2)", x -> 1500 <= x < 2000)
    ("[2, 2.5)", x -> 2000 <= x < 2500)
    ("[2.5, 3)", x -> 2500 <= x < 3000)
    ("[3, \$\\infty\$)", x -> 3000 <= x)
]

for d in [D[:ZH2], D[:ZH8], D[:DD]]
    M = UniMZ.read_all(UniMZ.read_ms2, joinpath(ROOT, "data", d[:id], ""), ".ms2") |> UniMZ.mapvalue(UniMZ.dict_by_id)
    d[:n_scan] = sum(length, values(M))
    for t in d[:tasks]
        t[:label] = split(t[:id], '@')[begin]
        path = joinpath(ROOT, "out", d[:id], t[:id], string(t[:run]))
        t[:n_spec] = read_n_spec(path, d[:engine])
        println("$(path)\t=> $(t[:n_spec] / d[:n_scan])")
        t[:df] = read_psm(path, d[:engine])
        t[:df].m = t[:df].mh .- UniMZ.mₚ
        t[:df].is_center = check_center(t[:df], M)
    end
end

py"""
def barwithlabel(ax, xs, ys, width, label, labels, fontsize):
    bar = ax.bar(xs, ys, width=width, label=label)
    ax.bar_label(bar, labels=labels, fontsize=fontsize) 
"""

fig = plt.figure(figsize=(12, 9))
gs = fig.add_gridspec(3, 3)
width = 0.4
Δ = [-0.5, 0.5]
for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]]), (j, t) in enumerate(d[:tasks])
    ax = fig.add_subplot(gs[j, i])
    j == 1 && ax.set_title(d[:id])
    xs = 2:6 |> collect
    ys = [[sum((t[:df].z .== z) .& (t[:df].is_center .== b)) for z in xs] for b in [true, false]]
    labels1 = [@sprintf("%.2f%%", y) for y in ys[1] ./ sum(t[:df].is_center) * 100]
    labels2 = [@sprintf("%.2f%%", y) for y in ys[2] ./ sum(.!t[:df].is_center) * 100]
    py"barwithlabel"(ax, xs .+ Δ[1] * width, ys[1], width, "Center Ion", labels1, 6)
    py"barwithlabel"(ax, xs .+ Δ[2] * width, ys[2], width, "Non-Center Ion", labels2, 6)
    ax.set_xlabel("charge state")
    ax.set_ylabel("#PSM")
    ax.set_xticks(xs, ["\$$(x)+\$" for x in xs])
    Plot.draw_index!(ax, "$('a' - 1 + i)$(j)."; x=-0.15, y=1.05, hide_axis=false)
    ax.legend(title=t[:label])
end

fig.tight_layout()
fig.subplots_adjust(hspace=0.25, wspace=0.25)
fig.savefig(joinpath(ROOT, "fig", "PepPre_dist_charge_center.pdf"))
plt.close(fig)

fig = plt.figure(figsize=(12, 9))
gs = fig.add_gridspec(3, 3)
width = 0.4
Δ = [-0.5, 0.5]
for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]]), (j, t) in enumerate(d[:tasks])
    ax = fig.add_subplot(gs[j, i])
    j == 1 && ax.set_title(d[:id])
    xs = 2:6 |> collect
    ys = [[sum(f.(t[:df].m) .& (t[:df].is_center .== b)) for (_, f) in ms] for b in [true, false]]
    labels1 = [@sprintf("%.2f%%", y) for y in ys[1] ./ sum(t[:df].is_center) * 100]
    labels2 = [@sprintf("%.2f%%", y) for y in ys[2] ./ sum(.!t[:df].is_center) * 100]
    py"barwithlabel"(ax, xs .+ Δ[1] * width, ys[1], width, "Center Ion", labels1, 6)
    py"barwithlabel"(ax, xs .+ Δ[2] * width, ys[2], width, "Non-Center Ion", labels2, 6)
    ax.set_xlabel("mass (kDa)")
    ax.set_ylabel("#PSM")
    ax.set_xticks(xs, [l for (l, _) in ms])
    Plot.draw_index!(ax, "$('a' - 1 + i)$(j)."; x=-0.15, y=1.05, hide_axis=false)
    ax.legend(title=t[:label])
end

fig.tight_layout()
fig.subplots_adjust(hspace=0.25, wspace=0.25)
fig.savefig(joinpath(ROOT, "fig", "PepPre_dist_mass_center.pdf"))
plt.close(fig)
