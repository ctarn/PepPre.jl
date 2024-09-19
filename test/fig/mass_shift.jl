include("util.jl")

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :task => Dict(:id => "PepPre@2", :run => 4.0),
    ),
    :ZH4 => Dict(
        :id => "Zubarev-Human-4",
        :task => Dict(:id => "PepPre@4", :run => 4.0),
    ),
    :ZH6 => Dict(
        :id => "Zubarev-Human-6",
        :task => Dict(:id => "PepPre@6", :run => 4.0),
    ),
    :ZH8 => Dict(
        :id => "Zubarev-Human-8",
        :task => Dict(:id => "PepPre@8", :run => 4.0),
    ),
)

for d in [D[:ZH2], D[:ZH4], D[:ZH6], D[:ZH8]]
    M = UniMZ.read_all(UniMZ.read_ms2, joinpath(ROOT, "data", d[:id], ""), ".ms2") |> UniMZ.mapvalue(UniMZ.dict_by_id)
    d[:n_scan] = sum(length, values(M))
    path = joinpath(ROOT, "out", d[:id], d[:task][:id], string(d[:task][:run]))
    d[:task][:n_spec] = read_n_spec(path, :pFind)
    d[:psm] = read_psm(path, :pFind)
    d[:task][:mass_shift] = [r.mz - M[r.file][r.scan].activation_center for r in eachrow(d[:psm])]
    d[:task][:mass_shift2] = d[:task][:mass_shift][d[:psm].z .== 2]
    d[:task][:mass_shift3] = d[:task][:mass_shift][d[:psm].z .== 3]
    d[:task][:mass_shift4] = d[:task][:mass_shift][d[:psm].z .== 4]
    d[:task][:mass_shift5] = d[:task][:mass_shift][d[:psm].z .== 5]
    d[:task][:mass_shift6] = d[:task][:mass_shift][d[:psm].z .== 6]
end

for s in [:mass_shift, :mass_shift2, :mass_shift3, :mass_shift4, :mass_shift5, :mass_shift6]
    fig = plt.figure(figsize=(8, 4))
    gs = fig.add_gridspec(1, 1)
    ax = fig.add_subplot(gs[1, 1])
    for d in [D[:ZH2], D[:ZH4], D[:ZH6], D[:ZH8]]
        ax.stairs(np.histogram(d[:task][s]; bins=-6.05:0.1:4.25)...; label=d[:id], linewidth=1)
    end
    ax.set_ylim(bottom=0)
    ax.set_xlabel("mass shift (Th)")
    ax.set_ylabel("#PSM")
    ax.legend(; loc="upper left")

    fig.tight_layout()

    fig.savefig(joinpath(ROOT, "fig", "PepPre_$(s).pdf"))
    plt.close(fig)
end
