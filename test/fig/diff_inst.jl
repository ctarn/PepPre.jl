include("util.jl")
include("diff_common.jl")

ε = 20e-6

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :isolation_width => 2,
        :engine => :pFind,
        :tasks => [
            Dict(:id => "EnumInst", :run => 1),
            Dict(:id => "PepPre@2", :run => 4.0),
            Dict(:id => "pParse@2", :run => -0.7),
            Dict(:id => "RawConverter", :run => 1),
            Dict(:id => "Monocle", :run => 1),
            Dict(:id => "Decon2LS", :run => 1),
            Dict(:id => "RAPID", :run => 1),
            Dict(:id => "MaxQuant", :run => 1),
            Dict(:id => "Dinosaur", :run => 1),
            Dict(:id => "PointIso", :run => 1),
            Dict(:id => "EnumIW", :run => 1),
            Dict(:id => "EnumEx", :run => 1),
        ],
    ),
    :ZH8 => Dict(
        :id => "Zubarev-Human-8",
        :isolation_width => 8,
        :engine => :pFind,
        :tasks => [
            Dict(:id => "EnumInst", :run => 1),
            Dict(:id => "PepPre@8", :run => 4.0),
            Dict(:id => "pParse@8", :run => 0.2),
            Dict(:id => "RawConverter", :run => 1),
            Dict(:id => "Monocle", :run => 1),
            Dict(:id => "Decon2LS", :run => 1),
            Dict(:id => "RAPID", :run => 1),
            Dict(:id => "MaxQuant", :run => 1),
            Dict(:id => "Dinosaur", :run => 1),
            Dict(:id => "PointIso", :run => 1),
            Dict(:id => "EnumIW", :run => 1),
            Dict(:id => "EnumEx", :run => 1),
        ],
    ),
    :DD => Dict(
        :id => "Dong-DSS-1.6",
        :isolation_width => 1.6,
        :engine => :pLink,
        :tasks => [
            Dict(:id => "EnumInst", :run => 1),
            Dict(:id => "PepPre", :run => 4.0),
            Dict(:id => "pParse", :run => -0.8),
            Dict(:id => "RawConverter", :run => 1),
            Dict(:id => "Monocle", :run => 1),
            Dict(:id => "Decon2LS", :run => 1),
            Dict(:id => "RAPID", :run => 1),
            Dict(:id => "MaxQuant", :run => 1),
            Dict(:id => "Dinosaur", :run => 1),
            Dict(:id => "PointIso", :run => 1),
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
        t_a[:label] = "Instrument"
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
    fig.savefig(joinpath(ROOT, "fig", "PepPre_diff_inst_$(D[:ZH2][:tasks][i_t][:label]).pdf"))
    plt.close(fig)
end
