include("util.jl")
include("diff_common.jl")

ε = 20e-6

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :isolation_width => 2,
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@2", :run => 4.0),
            Dict(:id => "pParse@2", :run => -0.7),
            Dict(:id => "RawConverter", :run => 1),
            Dict(:id => "Monocle", :run => 1),
            Dict(:id => "Decon2LS", :run => 1),
            Dict(:id => "RAPID", :run => 1),
            Dict(:id => "MaxQuant", :run => 1),
            Dict(:id => "Dinosaur", :run => 1),
            Dict(:id => "PointIso", :run => 1),
            Dict(:id => "EnumInst", :run => 4),
            Dict(:id => "EnumIW", :run => 1),
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
            Dict(:id => "RawConverter", :run => 1),
            Dict(:id => "Monocle", :run => 1),
            Dict(:id => "Decon2LS", :run => 1),
            Dict(:id => "RAPID", :run => 1),
            Dict(:id => "MaxQuant", :run => 1),
            Dict(:id => "Dinosaur", :run => 1),
            Dict(:id => "PointIso", :run => 1),
            Dict(:id => "EnumInst", :run => 4),
            Dict(:id => "EnumIW", :run => 1),
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
            Dict(:id => "RawConverter", :run => 1),
            Dict(:id => "Monocle", :run => 1),
            Dict(:id => "Decon2LS", :run => 1),
            Dict(:id => "RAPID", :run => 1),
            Dict(:id => "MaxQuant", :run => 1),
            Dict(:id => "Dinosaur", :run => 1),
            Dict(:id => "PointIso", :run => 1),
            Dict(:id => "EnumInst", :run => 4),
            Dict(:id => "EnumIW", :run => 1),
            Dict(:id => "EnumEx", :run => 1),
        ],
    ),
)

for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
    M2 = UniMZ.mapvalue(UniMZ.dict_by_id, UniMZ.read_all(UniMZ.read_ms2, joinpath(ROOT, "data", d[:id], ""), ".ms2"))
    d[:n_scan] = sum(x -> length(x), values(M2))
    for t in d[:tasks]
        t[:label] = split(t[:id], '@')[begin]
        path = joinpath(ROOT, "out", d[:id], t[:id], string(t[:run]))
        t[:n_spec] = read_n_spec(path, d[:engine])
        t[:df] = read_psm(path, d[:engine])
        t[:df].is_center = check_center(t[:df], M2)
        t[:ions] = load_mgf_pre(joinpath(ROOT, "out", d[:id], t[:id], string(t[:run]), ""))
        t[:ions_id] = load_psm_pre(t[:df])
        t[:ions_id_a] = load_psm_pre(t[:df][t[:df].is_center, :])
        t[:ions_id_o] = load_psm_pre(t[:df][.!(t[:df].is_center), :])
        t[:is_far] = check_far(t[:df], M2, 1)
    end
end

for i_t in 2:12
    fig = plt.figure(figsize=(12, 15))
    gs = fig.add_gridspec(6, 3)
    for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
        t_a, t_b = d[:tasks][begin], d[:tasks][i_t]
        for row in 1:6
            Plot.draw_index!(fig.add_subplot(gs[row, i]), "$('a' - 1 + row)$(i).")
        end
        draw!(fig, gs, 1, i, t_a[:label], t_b[:label], t_a[:ions], t_b[:ions])
        draw!(fig, gs, 2, i, t_a[:label], t_b[:label], t_a[:ions_id], t_b[:ions_id])
        draw!(fig, gs, 3, i, t_a[:label], t_b[:label], t_a[:ions_id_a], t_b[:ions_id_a])
        draw!(fig, gs, 4, i, t_a[:label], t_b[:label], t_a[:ions_id_o], t_b[:ions_id_o])

        a_b = filter_psm(t_a[:df], t_b[:ions_id])
        b_a = filter_psm(t_b[:df], t_a[:ions_id])

        a_b_exported = a_b .& .!filter_psm(t_a[:df], t_b[:ions])
        a_b_unexported = a_b .& filter_psm(t_a[:df], t_b[:ions])

        b_a_exported = b_a .& .!filter_psm(t_b[:df], t_a[:ions])
        b_a_unexported = b_a .& filter_psm(t_b[:df], t_a[:ions])

        ax1 = fig.add_subplot(gs[5, i])
        ax2 = fig.add_subplot(gs[6, i])
        labels = ["$(t_b[:label])\nexported", "$(t_b[:label])\nunexported"]
        data = sum.([a_b_exported, a_b_unexported])
        ax1.pie(data, labels=map(x -> "$(x[1])\n$(x[2]) PSM", zip(labels, data)), colors=["skyblue", "lightcoral"], autopct="%1.1f%%")
        labels = ["$(t_a[:label])\nexported", "$(t_a[:label])\nunexported"]
        data = sum.([b_a_exported, b_a_unexported])
        ax2.pie(data, labels=map(x -> "$(x[1])\n$(x[2]) PSM", zip(labels, data)), colors=["skyblue", "lightcoral"], autopct="%1.1f%%")
        ax1.text(0, 0, "$(sum(a_b))"; ha="center", va="center")
        ax2.text(0, 0, "$(sum(b_a))"; ha="center", va="center")
        ax1.axis("equal")
        ax2.axis("equal")
    end
    fig.tight_layout()
    plt.subplots_adjust(left=0.04, top=0.98, hspace=0.05)
    for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
        Plot.draw_title!(fig.add_subplot(gs[1, i]), d[:id])
        t_a, t_b = d[:tasks][begin], d[:tasks][i_t]
        if i == 1
            Plot.draw_ylabel!(fig.add_subplot(gs[1, 1]), "exported ions")
            Plot.draw_ylabel!(fig.add_subplot(gs[2, 1]), "identified ions")
            Plot.draw_ylabel!(fig.add_subplot(gs[3, 1]), "id. center ions")
            Plot.draw_ylabel!(fig.add_subplot(gs[4, 1]), "id. non-center ions")
            Plot.draw_ylabel!(fig.add_subplot(gs[5, 1]), "only id. by $(t_a[:label])")
            Plot.draw_ylabel!(fig.add_subplot(gs[6, 1]), "only id. by $(t_b[:label])")
        end
    end
    fig.savefig(joinpath(ROOT, "fig", "PepPre_diff_$(D[:ZH2][:tasks][i_t][:label]).pdf"))
    plt.close(fig)
end

fig = plt.figure(figsize=(12, 9))
gs = fig.add_gridspec(4, 3)
for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
    t_a, t_b = d[:tasks][begin], d[:tasks][end]
    for row in 1:4
        Plot.draw_index!(fig.add_subplot(gs[row, i]), "$('a' - 1 + row)$(i).")
    end
    draw!(fig, gs, 1, i, t_a[:label], t_b[:label], t_a[:ions], t_b[:ions])
    draw!(fig, gs, 2, i, t_a[:label], t_b[:label], t_a[:ions_id], t_b[:ions_id])

    a_b = filter_psm(t_a[:df], t_b[:ions_id])
    b_a = filter_psm(t_b[:df], t_a[:ions_id])

    a_b_exported = a_b .& .!filter_psm(t_a[:df], t_b[:ions])
    a_b_unexported = a_b .& filter_psm(t_a[:df], t_b[:ions])
    a_b_far = a_b_unexported .& t_a[:is_far]
    a_b_not = a_b_unexported .& .!t_a[:is_far]

    b_a_exported = b_a .& .!filter_psm(t_b[:df], t_a[:ions])
    b_a_unexported = b_a .& filter_psm(t_b[:df], t_a[:ions])

    ax1 = fig.add_subplot(gs[3, i])
    ax2 = fig.add_subplot(gs[4, i])
    labels = ["large m/z offset", "$(t_b[:label])\nexported", "not found"]
    data = sum.([a_b_far, a_b_exported, a_b_not])
    ax1.pie(data, labels=map(x -> "$(x[1])\n$(x[2]) PSM", zip(labels, data)), colors=["pink", "skyblue", "lightsalmon"], autopct="%1.1f%%")
    labels = ["$(t_a[:label])\nexported", "$(t_a[:label])\nunexported"]
    data = sum.([b_a_exported, b_a_unexported])
    ax2.pie(data, labels=map(x -> "$(x[1])\n$(x[2]) PSM", zip(labels, data)), colors=["skyblue", "lightcoral"], autopct="%1.1f%%")
    ax1.text(0, 0, "$(sum(a_b))"; ha="center", va="center")
    ax2.text(0, 0, "$(sum(b_a))"; ha="center", va="center")
    ax1.axis("equal")
    ax2.axis("equal")
end
fig.tight_layout()
plt.subplots_adjust(left=0.04, top=0.96, hspace=0.05)
for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
    Plot.draw_title!(fig.add_subplot(gs[1, i]), d[:id])
    t_a, t_b = d[:tasks][begin], d[:tasks][end]
    if i == 1
        Plot.draw_ylabel!(fig.add_subplot(gs[1, 1]), "exported ions")
        Plot.draw_ylabel!(fig.add_subplot(gs[2, 1]), "identified ions")
        Plot.draw_ylabel!(fig.add_subplot(gs[3, 1]), "only id. by $(t_a[:label])")
        Plot.draw_ylabel!(fig.add_subplot(gs[4, 1]), "only id. by $(t_b[:label])")
    end
end
fig.savefig(joinpath(ROOT, "fig", "PepPre_diff_vs_Enum.pdf"))
plt.close(fig)

fig = plt.figure(figsize=(12, 4))
gs = fig.add_gridspec(1, 3)
py"""
def bar(fig, ax, xs, yss, labels, bottoms, legend):
    bars = []
    for (ys, label, bottom) in zip(yss, labels, bottoms):
        bars.append(ax.bar(xs, ys, label=label, bottom=bottom))
    if legend:
        fig.legend(handles=bars, loc="lower center", ncol=5)
"""
for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
    ax = fig.add_subplot(gs[1, i])
    ax.set_title(d[:id])
    ab = []
    a_b_exported = []
    a_b_unexported = []
    b_a_exported = []
    b_a_unexported = []
    xticks = []
    folds = []
    t_a = d[:tasks][begin]
    n = size(t_a[:df], 1) / 100
    for i_t in 1:12
        t_b = d[:tasks][i_t]
        a_b = filter_psm(t_a[:df], t_b[:ions_id])
        b_a = filter_psm(t_b[:df], t_a[:ions_id])
        push!(ab, size(t_a[:df], 1) - sum(a_b))
        push!(a_b_exported, a_b .& .!filter_psm(t_a[:df], t_b[:ions]) |> sum)
        push!(a_b_unexported, a_b .& filter_psm(t_a[:df], t_b[:ions]) |> sum)
        push!(b_a_exported, b_a .& .!filter_psm(t_b[:df], t_a[:ions]) |> sum)
        push!(b_a_unexported, b_a .& filter_psm(t_b[:df], t_a[:ions]) |> sum)
        push!(xticks, t_b[:label])
        push!(folds, t_b[:n_spec] / d[:n_scan])
    end
    py"bar"(fig, ax, xticks,
        [ab, a_b_exported, a_b_unexported, -b_a_exported, -b_a_unexported] ./ n,
        ["Shared", "PepPre Gain (Other Exported)", "PepPre Gain (Other Unexported)", "PepPre Loss (PepPre Exported)", "PepPre Loss (PepPre Unexported)"],
        [nothing, ab ./ n, (ab + a_b_exported) ./ n, nothing, -b_a_exported ./ n],
        i == 1,
    )
    ax.set_xticks(0:11, xticks, rotation=45, ha="right")
    ax.set_yticks(ax.get_yticks(), map(x -> "$(abs(Int(x)))%", ax.get_yticks()))
    secax = ax.secondary_xaxis("top")
    secax.set_xticks(0:11, [@sprintf("%.1f×", f) for f in folds], rotation=45, ha="left")
    Plot.draw_index!(ax, "$('a' - 1 + i)."; x=-0.15, y=1.05, hide_axis=false)
end
fig.tight_layout()
plt.subplots_adjust(bottom=0.3)
fig.savefig(joinpath(ROOT, "fig", "PepPre_diff.pdf"))
plt.close(fig)
