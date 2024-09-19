include("util.jl")

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :engine => :pFind,
        :task => Dict(:id => "PepPre@2", :run => 4.0),
        :task_mono => Dict(:id => "PepPre-mono", :run => 4.0),
    ),
    :ZH8 => Dict(
        :id => "Zubarev-Human-8",
        :engine => :pFind,
        :task => Dict(:id => "PepPre@8", :run => 4.0),
        :task_mono => Dict(:id => "PepPre-mono", :run => 4.0),
    ),
    :DD => Dict(
        :id => "Dong-DSS-1.6",
        :engine => :pLink,
        :task => Dict(:id => "PepPre", :run => 4.0),
        :task_mono => Dict(:id => "PepPre-mono", :run => 4.0),
    ),
)

for d in [D[:ZH2], D[:ZH8], D[:DD]]
    d[:task][:label] = split(d[:task][:id], '@')[begin]
    path = joinpath(ROOT, "out", d[:id], d[:task][:id], string(d[:task][:run]))
    d[:task][:df] = read_psm(path, d[:engine])

    dfs = UniMZ.read_all(DataFrames.DataFrame ∘ CSV.File, joinpath(ROOT, "out", d[:id], d[:task_mono][:id], string(d[:task_mono][:run]), ""), ".precursor.csv")

    dfs = UniMZ.mapvalue(dfs) do rows
        ions = Dict{Int, Vector{Float64}}()
        for r in eachrow(rows)
            push!(get!(ions, r.scan, []), r.mono_error)
        end
        return ions
    end

    d[:task][:df].mono_inten_error .= NaN
    for r in eachrow(d[:task][:df])
        r.mono_inten_error = dfs[r.file*".precursor"][r.scan][r.idx_pre + 1]
    end

    d[:task][:df][d[:task][:df].mono_inten_error .< 0.0001, :mono_inten_error] .= 0.0
end

fig = plt.figure(figsize=(12, 4))
gs = fig.add_gridspec(1, 3)
for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
    d[:ax] = fig.add_subplot(gs[1, i])
    d[:ax].set_title(d[:id])
    τs = 0.0:0.0001:1.0
    d[:ax].plot(τs, [mean(d[:task][:df].mono_inten_error .<= τ) for τ in τs]; linewidth=1)
    d[:ax].set_xlabel("intensity error of monoisotopic peak")
    d[:ax].set_ylabel("#PSM (100% = $(size(d[:task][:df], 1)))")
    d[:ax].set_ylim(bottom=0)
    d[:ax].set_xticks(0.0:0.2:1.0, ["\$\\leq $(Int(τ * 100))\\%\$" for τ in 0.0:0.2:1.0])
    d[:ax].set_yticks(0.0:0.2:1.0, ["\$$(Int(x * 100))\\%\$" for x in 0.0:0.2:1.0])
    Plot.draw_index!(d[:ax], "$('a' - 1 + i)."; x=-0.15, y=1.02, hide_axis=false)
end

fig.tight_layout()
fig.savefig(joinpath(ROOT, "fig", "PepPre_mono_inten_error.pdf"))
plt.close(fig)
