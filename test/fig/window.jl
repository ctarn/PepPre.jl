include("util.jl")

D = Dict(
    :id => "Zubarev-Human",
    :ws_inst => 2:2:8,
    :ws_algo => 2:2:8,
    :tasks => [
        Dict(:id => "PepPre", :runs => 3.8:0.2:4),
        Dict(:id => "pParse", :runs => 1:-0.1:-1),
    ],
)

fold_std = 4

D[:n] = zeros(Int, length(D[:ws_algo]), length(D[:ws_inst]), length(D[:tasks]))
for (i_inst, w_inst) in enumerate(D[:ws_inst])
    n_scan = UniMZ.count_msx(joinpath(ROOT, "data", "$(D[:id])-$(w_inst)", ""), ".ms2")
    for (i_algo, w_algo) in enumerate(D[:ws_algo])
        for (i_task, t) in enumerate(D[:tasks])
            fold_hit = Inf
            path_hit = nothing
            for run in t[:runs]
                path = joinpath(ROOT, "out", "$(D[:id])-$(w_inst)", "$(t[:id])@$(w_algo)", string(run))
                fold = read_n_spec(path, :pFind) / n_scan
                println("$(path)\t=> $(fold)")
                if abs(fold - fold_std) < abs(fold_hit - fold_std)
                    fold_hit, path_hit = fold, path
                end
            end
            @info "HIT: $(path_hit)\t=> $(fold_hit)"
            D[:n][i_algo, i_inst, i_task] = read_n_id_spec(path_hit, :pFind)
        end
    end
end

fig = plt.figure(figsize=(8, 4))
gs = fig.add_gridspec(1, 2)

vmin, vmax = extrema(D[:n])
for (i_task, t) in enumerate(D[:tasks])
    ax = fig.add_subplot(gs[1, i_task])
    ax.set_title(t[:id])
    ax.imshow(D[:n][:, :, i_task], cmap="GnBu", aspect="auto"; vmin, vmax)
    ax.set_xticks(eachindex(D[:ws_inst]) .- 1, ["$(x) Th" for x in D[:ws_inst]])
    ax.set_yticks(eachindex(D[:ws_algo]) .- 1, ["$(x) Th" for x in D[:ws_algo]])
    ax.set_xlabel("window size (instrument)")
    ax.set_ylabel("window size (algorithm)")
    ax.grid(visible=false)
    ax.invert_yaxis()
    ax.tick_params(left=false, bottom=false)
    for i_inst in eachindex(D[:ws_inst]), i_algo in eachindex(D[:ws_algo])
        ax.text(i_inst - 1, i_algo - 1, D[:n][i_algo, i_inst, i_task], va="center", ha="center", fontsize=12)
        (i_task == 1) && ax.text(i_inst - 1, i_algo - 1, @sprintf("\n\n\n(%+.2f%%)", D[:n][i_algo, i_inst, 1] / D[:n][i_algo, i_inst, 2] * 100 - 100), va="center", ha="center", fontsize=8)
    end
end

plt.tight_layout()

for i in eachindex(D[:tasks])
    Plot.draw_index!(fig.add_subplot(gs[1, i]), "$('a' + i - 1)."; x=-0.1, y=0.95)
end

fig.savefig(joinpath(ROOT, "fig", "PepPre_window.pdf"))
plt.close(fig)
