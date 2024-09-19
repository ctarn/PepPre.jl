include("util.jl")

ls = Dict(
    "PepPre" => :solid,
    "pParse" => :solid,
    "RawConverter" => :solid,
    "Monocle" => :solid,
    "Decon2LS" => :solid,
    "RAPID" => :solid,
    "MaxQuant" => :dashed,
    "Dinosaur" => :dashed,
    "PointIso" => :dashed,
    "EnumInst" => :dashdot,
    "EnumIW" => :dashdot,
    "EnumEx" => :dashdot,
)

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
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

for d in [D[:ZH2], D[:ZH8], D[:DD]]
    M = UniMZ.read_all(UniMZ.read_ms2, joinpath(ROOT, "data", d[:id], ""), ".ms2") |> UniMZ.mapvalue(UniMZ.dict_by_id)
    d[:n_scan] = sum(length, values(M))
    for t in d[:tasks]
        t[:label] = split(t[:id], '@')[begin]
        path = joinpath(ROOT, "out", d[:id], t[:id], string(t[:run]))
        t[:n_spec] = read_n_spec(path, d[:engine])
        println("$(path)\t=> $(t[:n_spec] / d[:n_scan])")
        t[:df] = read_psm(path, d[:engine])
        t[:n] = calc_ion(t[:df], M, d[:engine])
    end
end

fig = plt.figure(figsize=(12, 4))
gs = fig.add_gridspec(1, 3)
for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
    d[:ax] = fig.add_subplot(gs[1, i])
    d[:ax].set_title(d[:id])
    τs = 0.5:0.01:1.5
    for t in d[:tasks]
        d[:ax].plot(τs, [sum(t[:n] .>= τ) for τ in τs]; label=t[:label], linewidth=1, linestyle=ls[t[:label]])
    end
    d[:ax].set_xlabel("normalized #fragment")
    d[:ax].set_ylabel("#PSM")
    d[:ax].set_ylim(bottom=0)
    d[:ax].set_xticks(0.6:0.2:1.4, ["\$\\geq $(τ)\$" for τ in 0.6:0.2:1.4])
    Plot.draw_index!(d[:ax], "$('a' - 1 + i)."; x=-0.15, y=1.02, hide_axis=false)
end

D[:DD][:ax].legend(fontsize="small")

fig.tight_layout()
fig.savefig(joinpath(ROOT, "fig", "PepPre_fragment.pdf"))
plt.close(fig)
