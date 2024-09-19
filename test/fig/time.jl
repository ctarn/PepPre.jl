include("util.jl")

D = [
    (name="Zubarev-Human-2", time=[246.66, 244.83, 245.15]),
    (name="Zubarev-Human-4", time=[310.10, 313.80, 312.66]),
    (name="Zubarev-Human-6", time=[417.45, 423.73, 416.31]),
    (name="Zubarev-Human-8", time=[516.36, 513.80, 513.79]),
]
fig = plt.figure(figsize=(6, 4))
gs = fig.add_gridspec(1, 1)
ax = fig.add_subplot(gs[1, 1])
width = 0.2
Δ = -1:1 |> collect
xs = eachindex(D) |> collect
for i in eachindex(Δ)
    ax.bar(xs .+ Δ[i] * width, [d.time[i] for d in D], width, label="Replicate #$(i)")
end
ax.set_ylabel("time (sec)")
ax.set_xticks(xs, [d.name for d in D])
ax.legend()

fig.tight_layout()
fig.savefig(joinpath(ROOT, "fig", "PepPre_time.pdf"))
plt.close(fig)
