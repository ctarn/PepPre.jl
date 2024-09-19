include("util.jl")

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
        :fasta => "dong-syn.fasta",
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

deamidated(r) = any(m -> m.id == Symbol("Deamidated[N]"), r.mod)
deamidated_xl(r) = any(mods -> any(m -> m.id == Symbol("Deamidated[N]"), mods), [r.mod_a, r.mod_b])

for d in [D[:ZH2], D[:ZH8]]
    d[:n_scan] = UniMZ.count_msx(joinpath(ROOT, "data", d[:id], ""), ".ms2")
    for t in d[:tasks]
        path = joinpath(ROOT, "out", d[:id], t[:id], string(t[:run]))
        t[:n_spec] = read_n_spec(path, :pFind)
        t[:label] = split(t[:id], '@')[begin] * @sprintf(" (%.1f×)", t[:n_spec] ./ d[:n_scan])
        df = read_psm(path, :pFind)
        t[:error] = df.mz_error
        t[:error_deamidated] = df.mz_error[deamidated.(eachrow(df))]
    end
end

d = D[:DD]
d[:n_scan] = UniMZ.count_msx(joinpath(ROOT, "data", d[:id], ""), ".ms2")
for t in d[:tasks]
    path = joinpath(ROOT, "out", d[:id], t[:id], string(t[:run]))
    t[:n_spec] = read_n_spec(path, :pLink)
    t[:label] = split(t[:id], '@')[begin] * @sprintf(" (%.1f×)", t[:n_spec] ./ d[:n_scan])
    df = read_psm(path, :pLink)
    t[:error] = df.mz_error
    t[:error_deamidated] = df.mz_error[deamidated_xl.(eachrow(df))]
end

for s in [:error, :error_deamidated]
    fig = plt.figure(figsize=(12, 6))
    gs = fig.add_gridspec(2, 3)
    for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
        d[:ax1] = fig.add_subplot(gs[1, i])
        d[:ax2] = fig.add_subplot(gs[2, i])
        d[:ax1].set_title(d[:id])

        for t in d[:tasks][1:6]
            d[:ax1].stairs(np.histogram(t[s]; bins=-20.5:20.5)...; label=t[:label], linewidth=1.5)
        end
        for t in [d[:tasks][1], d[:tasks][7:end]...]
            d[:ax2].stairs(np.histogram(t[s]; bins=-20.5:20.5)...; label=t[:label], linewidth=1.5)
        end

        for (j, ax) in enumerate([d[:ax1], d[:ax2]])
            ax.set_ylim(bottom=0)
            ax.set_xlabel("m/z error (ppm)")
            ax.set_ylabel("#PSM")
            ax.legend(; loc="upper left", fontsize="small")
            UniMZ.Plot.draw_index!(ax, "$('a' + i - 1)$(j)."; x=-0.15, y=1.04, hide_axis=false)
        end
    end

    fig.tight_layout()
    fig.subplots_adjust(hspace=0.2, wspace=0.25)
    fig.savefig(joinpath(ROOT, "fig", "PepPre_mass_$(s).pdf"))
    plt.close(fig)
end
