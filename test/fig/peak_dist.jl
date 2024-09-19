include("util.jl")

M1 = UniMZ.read_all(UniMZ.read_ms1, joinpath(ROOT, "data", "Zubarev-Human-8", ""), ".ms1") |> UniMZ.mapvalue(UniMZ.dict_by_id) |> values |> only
M2 = UniMZ.read_all(UniMZ.read_ms2, joinpath(ROOT, "data", "Zubarev-Human-8", ""), ".ms2") |> UniMZ.mapvalue(UniMZ.dict_by_id) |> values |> only

mzs = map(values(M2)) do m
    peaks = UniMZ.query_δ(M1[m.pre].peaks, m.activation_center, 16.05)
    return [p.mz - m.activation_center for p in peaks]
end

mzs = reduce(vcat, mzs)

fig = plt.figure(figsize=(8, 4))
gs = fig.add_gridspec(1, 1)
ax = fig.add_subplot(gs[1, 1])
ax.stairs(np.histogram(mzs; bins=-16.05:0.1:16.05)...; linewidth=1)
ax.set_ylim(bottom=0)
ax.set_xlabel("mass shift (Th)")
ax.set_ylabel("#peak")

fig.tight_layout()

fig.savefig(joinpath(ROOT, "fig", "PepPre_peak_dist.pdf"))
plt.close(fig)

mzs = map(values(M2)) do m
    return [p.mz for p in m.peaks]
end

mzs = reduce(vcat, mzs)

fig = plt.figure(figsize=(64, 4))
gs = fig.add_gridspec(1, 1)
ax = fig.add_subplot(gs[1, 1])
ax.stairs(np.histogram(mzs; bins=499.01:0.02:1000.01)...; linewidth=1)
ax.set_ylim(bottom=0)
ax.set_xlabel("m/z (Th)")
ax.set_ylabel("#peak")

fig.tight_layout()

fig.savefig(joinpath(ROOT, "fig", "PepPre_peak_dist_all_MS2.pdf"))
plt.close(fig)
