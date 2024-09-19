include("util.jl")

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :engine => :pFind,
        :task => Dict(:id => "EnumEx", :run => 1),
    ),
    :ZH8 => Dict(
        :id => "Zubarev-Human-8",
        :engine => :pFind,
        :task => Dict(:id => "EnumEx", :run => 1),
    ),
    :DD => Dict(
        :id => "Dong-DSS-1.6",
        :engine => :pLink,
        :task => Dict(:id => "EnumEx", :run => 1),
    ),
)

calc_error(psm, M1, M2, V) = begin
    ms1 = M1[psm[:file]][M2[psm[:file]][psm[:scan]].pre]
    mz = UniMZ.query_near(ms1.peaks, (; psm.mz); by=x -> x.mz).mz
    mz2_calc = UniMZ.ipv_mz(mz, psm.z, 2, V)
    mz2 = UniMZ.query_near(ms1.peaks, (; mz=mz2_calc); by=x -> x.mz).mz
    return UniMZ.error_ppm(mz2_calc, mz2)
end

for d in [D[:ZH2], D[:ZH8], D[:DD]]
    M1 = UniMZ.read_all(UniMZ.read_ms1, joinpath(ROOT, "data", d[:id], ""), ".ms1") |> UniMZ.mapvalue(UniMZ.dict_by_id)
    M2 = UniMZ.read_all(UniMZ.read_ms2, joinpath(ROOT, "data", d[:id], ""), ".ms2") |> UniMZ.mapvalue(UniMZ.dict_by_id)
    d[:n_scan] = sum(length, values(M2))
    t = d[:task]
    t[:label] = split(t[:id], '@')[begin]
    path = joinpath(ROOT, "out", d[:id], t[:id], string(t[:run]))
    t[:n_spec] = read_n_spec(path, d[:engine])
    println("$(path)\t=> $(t[:n_spec] / d[:n_scan])")
    t[:df] = read_psm(path, d[:engine])
    t[:error] = [calc_error(r, M1, M2, Global_V) for r in eachrow(t[:df])]
end

fig = plt.figure(figsize=(12, 4))
gs = fig.add_gridspec(1, 3)
for (i, d) in enumerate([D[:ZH2], D[:ZH8], D[:DD]])
    d[:ax] = fig.add_subplot(gs[1, i])
    d[:ax].set_title(d[:id])
    d[:ax].stairs(np.histogram(d[:task][:error]; bins=-20.5:20.5)...; linewidth=1.5)
    d[:ax].set_xlabel("m/z error of second isotopic peak (ppm)")
    d[:ax].set_ylabel("#PSM")
    d[:ax].set_ylim(bottom=0)
    Plot.draw_index!(d[:ax], "$('a' - 1 + i)."; x=-0.15, y=1.02, hide_axis=false)
end

fig.tight_layout()
fig.savefig(joinpath(ROOT, "fig", "PepPre_enum_iso_error.pdf"))
plt.close(fig)
